#!/usr/bin/env python3
"""Turn an AI-generated image (1024px-class) into a native-size pixel-art PNG.

docs/SPRITE_REGEN_32PX.md is the workflow this script belongs to.

sprite mode (default)
  1. Background: uses the real alpha channel when the image has one. Otherwise
     the background is the solid color of the image border (or --key), removed
     by flood fill from the border so same-colored pixels inside the subject
     survive. A non-uniform border (e.g. a painted checkerboard "fake
     transparency") is rejected instead of being baked into the asset.
  2. Crops to the subject, fits it into the canvas minus --pad, keeps aspect.
  3. Area-averages down to the canvas (premultiplied, so no background fringe),
     makes alpha binary and limits the palette to --colors.

tile mode
  Full-bleed seamless texture: center-crop to aspect, area-average down,
  limit palette. Prints a seam score so non-tileable results are caught.

Never overwrites an existing output unless --force is given.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

import numpy as np
from PIL import Image


WORK_MAX_SIDE = 512          # bg removal runs at this resolution (fast, still 8x+ target)
BORDER_RING_PX = 4
UNIFORM_BORDER_SPREAD = 0.5  # 85th-pct border distance to the bg color must stay under tolerance * this
LIGHT_KEY_SATURATION = 60    # max-min channel spread below this = gray/white key, risky for light subjects
TILE_SEAM_WARN = 1.5         # opposite-edge diff vs. the texture's own 90th-pct neighbour diff


def parse_hex(value: str) -> tuple[int, int, int]:
    v = value.lstrip("#")
    if len(v) != 6:
        raise argparse.ArgumentTypeError(f"expected RRGGBB, got {value!r}")
    return int(v[0:2], 16), int(v[2:4], 16), int(v[4:6], 16)


def border_ring(arr: np.ndarray, px: int) -> np.ndarray:
    return np.concatenate([
        arr[:px].reshape(-1, arr.shape[-1]),
        arr[-px:].reshape(-1, arr.shape[-1]),
        arr[px:-px, :px].reshape(-1, arr.shape[-1]),
        arr[px:-px, -px:].reshape(-1, arr.shape[-1]),
    ])


def color_distance(rgb: np.ndarray, key: np.ndarray) -> np.ndarray:
    return np.sqrt(((rgb.astype(np.int32) - key.astype(np.int32)) ** 2).sum(axis=-1))


def flood_from_border(candidate: np.ndarray) -> np.ndarray:
    """Pixels of `candidate` connected (4-neighbour) to the image border."""
    region = np.zeros_like(candidate)
    region[0, :] = candidate[0, :]
    region[-1, :] = candidate[-1, :]
    region[:, 0] |= candidate[:, 0]
    region[:, -1] |= candidate[:, -1]
    while True:
        grown = region.copy()
        grown[1:, :] |= region[:-1, :]
        grown[:-1, :] |= region[1:, :]
        grown[:, 1:] |= region[:, :-1]
        grown[:, :-1] |= region[:, 1:]
        grown &= candidate
        if np.array_equal(grown, region):
            return region
        region = grown


def remove_background(img: Image.Image, key: tuple[int, int, int] | None, tolerance: float) -> Image.Image:
    arr = np.asarray(img.convert("RGBA"))
    ring = border_ring(arr, BORDER_RING_PX)
    if (ring[:, 3] < 128).mean() > 0.5:
        print("  background: real alpha channel")
        return img.convert("RGBA")

    rgb = arr[..., :3]
    key_rgb = np.array(key if key else np.median(ring[:, :3], axis=0), dtype=np.int32)
    key_hex = f"#{key_rgb[0]:02X}{key_rgb[1]:02X}{key_rgb[2]:02X}"
    spread = np.percentile(color_distance(ring[:, :3], key_rgb), 85)
    if spread > tolerance * UNIFORM_BORDER_SPREAD:
        raise SystemExit(
            f"error: border is not a single solid color (85th-pct distance {spread:.0f} from {key_hex}). "
            "Likely a painted checkerboard or scenery background. Regenerate on a flat solid "
            "#FF00FF background (see docs/SPRITE_REGEN_32PX.md)."
        )
    if key_rgb.max() - key_rgb.min() < LIGHT_KEY_SATURATION:
        print(f"  warning: background {key_hex} is gray/white - light parts of the subject touching it "
              "may be cut. Prefer a #FF00FF background.")
    dist = color_distance(rgb, key_rgb)
    bg = flood_from_border(dist <= tolerance)
    # Eat the anti-aliased halo (subject blended with the key color) touching the background.
    halo = dist <= tolerance * 2.0
    for _ in range(2):
        near_bg = bg.copy()
        near_bg[1:, :] |= bg[:-1, :]
        near_bg[:-1, :] |= bg[1:, :]
        near_bg[:, 1:] |= bg[:, :-1]
        near_bg[:, :-1] |= bg[:, 1:]
        bg = bg | (near_bg & halo)
    out = arr.copy()
    out[..., 3] = np.where(bg, 0, 255).astype(np.uint8)
    print(f"  background: solid {key_hex} removed ({bg.mean():.0%} of image)")
    return Image.fromarray(out, "RGBA")


def area_downscale(img: Image.Image, size: tuple[int, int]) -> Image.Image:
    # Premultiplied so fully transparent pixels contribute no color to edge texels.
    return img.convert("RGBa").resize(size, Image.Resampling.BOX).convert("RGBA")


def limit_palette(img: Image.Image, colors: int, alpha_threshold: int) -> tuple[Image.Image, int]:
    arr = np.asarray(img).copy()
    opaque = arr[..., 3] >= alpha_threshold
    arr[..., 3] = np.where(opaque, 255, 0).astype(np.uint8)
    if not opaque.any():
        raise SystemExit("error: nothing left after background removal - check --key / --tolerance.")
    samples = arr[opaque][:, :3]
    sample_img = Image.fromarray(samples.reshape(1, -1, 3), "RGB")
    quantized = sample_img.quantize(colors=colors, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE)
    # quantize(palette=...) matches against all 256 entries; pad with a real color
    # instead of the default black so dark pixels don't snap to an unused #000000.
    count = len(quantized.getcolors())
    entries = quantized.getpalette()[: 3 * count]
    palette_img = Image.new("P", (1, 1))
    palette_img.putpalette(entries + entries[-3:] * (256 - count))
    mapped = Image.fromarray(arr[..., :3], "RGB").quantize(palette=palette_img, dither=Image.Dither.NONE).convert("RGB")
    out = np.dstack([np.asarray(mapped), arr[..., 3]])
    out[~opaque, :3] = 0
    used = len(np.unique(out[opaque][:, :3], axis=0))
    return Image.fromarray(out.astype(np.uint8), "RGBA"), used


def add_outline(img: Image.Image, color: tuple[int, int, int]) -> Image.Image:
    arr = np.asarray(img).copy()
    solid = arr[..., 3] > 0
    edge = np.zeros_like(solid)
    edge[1:, :] |= solid[:-1, :]
    edge[:-1, :] |= solid[1:, :]
    edge[:, 1:] |= solid[:, :-1]
    edge[:, :-1] |= solid[:, 1:]
    edge &= ~solid
    arr[edge] = (*color, 255)
    return Image.fromarray(arr, "RGBA")


def desaturate(img: Image.Image, amount: float) -> Image.Image:
    arr = np.asarray(img).astype(np.float32)
    luma = arr[..., 0] * 0.299 + arr[..., 1] * 0.587 + arr[..., 2] * 0.114
    arr[..., :3] = arr[..., :3] * (1.0 - amount) + luma[..., None] * amount
    return Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8), "RGBA")


def center_crop_to_aspect(img: Image.Image, width: int, height: int) -> Image.Image:
    target = width / height
    if img.width / img.height > target:
        w = int(img.height * target)
        left = (img.width - w) // 2
        return img.crop((left, 0, left + w, img.height))
    h = int(img.width / target)
    top = (img.height - h) // 2
    return img.crop((0, top, img.width, top + h))


def process_sprite(src: Image.Image, args: argparse.Namespace) -> Image.Image:
    work = src.convert("RGBA")
    if max(work.size) > WORK_MAX_SIDE:
        ratio = WORK_MAX_SIDE / max(work.size)
        work = work.resize((round(work.width * ratio), round(work.height * ratio)), Image.Resampling.LANCZOS)
    keyed = remove_background(work, args.key, args.tolerance)
    bbox = keyed.getchannel("A").point(lambda a: 255 if a >= 128 else 0).getbbox()
    if bbox is None:
        raise SystemExit("error: no subject found after background removal.")
    subject = keyed.crop(bbox)
    inner_w, inner_h = args.size - 2 * args.pad, args.height - 2 * args.pad
    scale = min(inner_w / subject.width, inner_h / subject.height)
    fit = (max(1, round(subject.width * scale)), max(1, round(subject.height * scale)))
    small = area_downscale(subject, fit)
    if args.desaturate > 0:
        small = desaturate(small, args.desaturate)
    small, used = limit_palette(small, args.colors, args.alpha_threshold)
    canvas = Image.new("RGBA", (args.size, args.height), (0, 0, 0, 0))
    x = (args.size - fit[0]) // 2
    y = (args.height - fit[1]) if args.anchor == "bottom" else (args.height - fit[1]) // 2
    if args.anchor == "bottom":
        y -= args.pad
    canvas.alpha_composite(small, (x, y))
    if args.outline:
        if args.pad < 1:
            raise SystemExit("error: --outline needs --pad >= 1 so the outline fits inside the canvas.")
        canvas = add_outline(canvas, args.outline)
    print(f"  subject: {fit[0]}x{fit[1]} in {args.size}x{args.height} canvas, {used} colors")
    return canvas


def process_tile(src: Image.Image, args: argparse.Namespace) -> Image.Image:
    cropped = center_crop_to_aspect(src.convert("RGBA"), args.size, args.height)
    small = area_downscale(cropped, (args.size, args.height))
    if args.desaturate > 0:
        small = desaturate(small, args.desaturate)
    small, used = limit_palette(small, args.colors, 0)
    seam = tile_seam_ratio(np.asarray(small).astype(np.int32)[..., :3])
    print(f"  tile: {args.size}x{args.height}, {used} colors, seam ratio {seam:.2f}")
    if seam > TILE_SEAM_WARN:
        print(f"  warning: seam ratio > {TILE_SEAM_WARN} - wrap-around edges differ more than the texture "
              "itself; regenerate as seamless/tileable.")
    return small


def tile_seam_ratio(rgb: np.ndarray) -> float:
    """How much the wrap-around edge (last->first column/row) stands out from the
    texture's own neighbour-to-neighbour variation. ~1 = seamless."""
    ratios = []
    for axis in (0, 1):
        moved = np.moveaxis(rgb, axis, 0)
        inner = np.abs(np.diff(moved, axis=0)).mean(axis=(1, 2))
        wrap = np.abs(moved[-1] - moved[0]).mean()
        ratios.append(wrap / max(np.percentile(inner, 90), 1.0))
    return float(max(ratios))


def save_preview(img: Image.Image, path: Path, factor: int = 8) -> None:
    big = img.resize((img.width * factor, img.height * factor), Image.Resampling.NEAREST)
    bg = Image.new("RGBA", big.size, (58, 62, 78, 255))
    bg.alpha_composite(big)
    path.parent.mkdir(parents=True, exist_ok=True)
    bg.convert("RGB").save(path, "PNG")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("input", type=Path, help="AI-generated source image")
    parser.add_argument("output", type=Path, help="native-size PNG to write (e.g. godot/assets/sprites/char_vagrant.png)")
    parser.add_argument("--size", type=int, required=True, help="canvas width in px")
    parser.add_argument("--height", type=int, help="canvas height in px (default: same as --size)")
    parser.add_argument("--mode", choices=("sprite", "tile"), default="sprite")
    parser.add_argument("--pad", type=int, default=0,
                        help="transparent margin inside the canvas (sprite mode). Keep 0 when the source was drawn on "
                             "the exact target grid - any shrink resamples the grid and softens it")
    parser.add_argument("--anchor", choices=("center", "bottom"), default="center", help="subject placement (sprite mode)")
    parser.add_argument("--colors", type=int, default=24, help="max palette size")
    parser.add_argument("--key", type=parse_hex, help="background color RRGGBB (default: detected from the border)")
    parser.add_argument("--tolerance", type=float, default=70.0, help="RGB distance counted as background")
    parser.add_argument("--alpha-threshold", type=int, default=128, help="alpha cut for binary transparency")
    parser.add_argument("--outline", type=parse_hex, help="add a 1px outline of this color RRGGBB")
    parser.add_argument("--desaturate", type=float, default=0.0, help="0..1, pull colors toward gray (tint-friendly tiles/decor)")
    parser.add_argument("--preview", type=Path, help="also write an 8x nearest-neighbor preview PNG here")
    parser.add_argument("--force", action="store_true", help="overwrite an existing output")
    args = parser.parse_args()
    if args.height is None:
        args.height = args.size
    if not 0.0 <= args.desaturate <= 1.0:
        parser.error("--desaturate must be within 0..1")
    return args


def main() -> int:
    args = parse_args()
    if args.output.exists() and not args.force:
        print(f"error: {args.output} exists; pass --force to overwrite.", file=sys.stderr)
        return 1
    src = Image.open(args.input)
    print(f"{args.input} ({src.width}x{src.height}) -> {args.output}")
    result = process_tile(src, args) if args.mode == "tile" else process_sprite(src, args)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    result.save(args.output, "PNG", optimize=True)
    if args.preview:
        save_preview(result, args.preview)
        print(f"  preview: {args.preview}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
