#!/usr/bin/env python3
"""Redraw the battlefield sprites with Codex image generation, then pixelize them
into the game (docs/SPRITE_REGEN_32PX.md).

  python scripts/codex_generate_sprites.py                  # everything missing in art/raw/, then apply all
  python scripts/codex_generate_sprites.py enemy_hound --regen   # redraw one asset
  python scripts/codex_generate_sprites.py --no-apply       # only generate raw images

1. For each asset without art/raw/<name>.png (or every named one with --regen) it
   runs `codex exec` with the asset's prompt; Codex's image_generation tool saves
   the PNG under ~/.codex/generated_images/<session>/, which is copied to art/raw/.
2. Unless --no-apply, every selected asset is run through scripts/pixelize_sprite.py
   into its game path (overwriting) with an 8x preview in art/preview/.

Requires the Codex CLI logged in (`codex login`). art/ is git-ignored.
"""

from __future__ import annotations

import argparse
import re
import shutil
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
ART = REPO_ROOT / "art"
GEN_DIR = Path.home() / ".codex" / "generated_images"
PARALLEL = 5
CODEX_TIMEOUT_S = 420

HEAD = "Use your image generation tool to create exactly one image. Do not write code or run shell commands.\n\n"
BG = ("- Background: one flat solid pure {bg} everywhere outside the subject. No checkerboard, no transparency "
      "pattern, no shadow, no scenery, no frame, no text, no letters.\n- Square image.\n")
COMMON = ("- Max 16 colors, flat shading with one highlight and one shadow tone per material, 1-pixel dark outline "
          "(#1A1424) around the silhouette, light from the top-left.\n"
          "- Keep colors mid-to-light so it stands out on a dark battlefield; no large near-black areas.\n"
          "- Dark-fantasy night world palette accents: pale moonlight #DDEBFF, ember gold #F2C66A.\n")

TEMPLATES = {
    "char": ("A 16-bit era RPG character sprite that is exactly {n}x{n} pixels, displayed enlarged with "
             "nearest-neighbor scaling (every original pixel becomes a large crisp square). Style like a classic "
             "overworld sprite: cute chibi proportions with a large head, readable at its tiny native size, very "
             "limited detail. Front-facing, full body, centered.\n"),
    "enemy": ("A 16-bit era RPG monster sprite that is exactly {n}x{n} pixels, displayed enlarged with "
              "nearest-neighbor scaling (every original pixel becomes a large crisp square). Chunky, readable "
              "silhouette at its tiny native size, cute-but-menacing proportions, very limited detail. Facing the "
              "viewer (front or three-quarter front), centered, filling most of the frame.\n"),
    "icon": ("A 16-bit era RPG inventory icon that is exactly {n}x{n} pixels, displayed enlarged with "
             "nearest-neighbor scaling (every original pixel becomes a large crisp square). One bold, instantly "
             "readable object, centered, filling about 85% of the frame, simple shapes.\n"),
    "proj": ("A tiny 16-bit era projectile sprite that is exactly {n}x{h} pixels, displayed enlarged with "
             "nearest-neighbor scaling (every original pixel becomes a large crisp square). The object lies "
             "horizontally across the middle of the image with its tip pointing to the RIGHT edge. No motion "
             "trail, no speed lines.\n"),
    "tile": ("A seamless tileable top-down ground texture for a 16-bit pixel art game, a {n}x{n} pixel tile "
             "displayed enlarged with nearest-neighbor scaling (every original pixel a crisp square block). "
             "Neutral light gray only (no hue, it will be color-tinted in the engine), average value around "
             "#B0B0B0, low contrast. Must tile perfectly on all four sides. Fills the whole image edge to edge. "
             "No objects, no characters, no text, no border, no vignette.\n"),
    "ui": ("A 16-bit era game UI icon that is exactly {n}x{n} pixels, displayed enlarged with nearest-neighbor "
           "scaling (every original pixel becomes a large crisp square). Clean, bold, centered, filling about 90% "
           "of the frame.\n"),
}

S = "godot/assets/sprites/"
U = S + "ui/"
ASSETS = [
    # name, template, n, h, target path, extra pixelize args, subject, bg
    ("char_vagrant", "char", 32, 32, S + "char_vagrant.png", [], "A lone wandering swordsman in a blue hooded travel cloak, silver shoulder guard, pale-blue glowing longsword held down at the side. Accent moonlight blue #7CB8FF. Silhouette: hood + long sword."),
    ("char_spirit_sister", "char", 32, 32, S + "char_spirit_sister.png", [], "A young nun in a dark navy habit with a white wimple and veil, hands clasped around a small silver rosary, two tiny glowing cyan spirit orbs floating at her shoulders. Accent cyan #66F2F2. Silhouette: veil + floating orbs."),
    ("char_hunter", "char", 32, 32, S + "char_hunter.png", [], "A nimble archer in brown leather with a short green hood, holding a short wooden bow in one hand, a quiver of arrows on the back. Accent star gold #F2D966 on the arrow fletching. Silhouette: bow + quiver."),
    ("char_berserker", "char", 32, 32, S + "char_berserker.png", [], "A huge broad-shouldered barbarian warrior with bare muscular arms, an iron helmet with two horns, a wild beard, gripping a great axe wrapped in thorny green vines. Accent thorn green #80F266. Silhouette: wide bulky body + horns + big axe."),
    ("char_pyromancer", "char", 32, 32, S + "char_pyromancer.png", [], "A fire mage in a dark red robe with a tall pointed hood, glowing ember-orange hands, a small living flame wisp floating beside them. Accent ember orange #FF8C33. Silhouette: pointed hood + flame."),
    ("enemy_slime", "enemy", 28, 28, S + "enemy_slime.png", [], "A small round gelatinous slime blob, moss green, glossy top-left highlight, two dot eyes, slightly squashed."),
    ("enemy_bat", "enemy", 24, 24, S + "enemy_bat.png", [], "A small night bat facing the viewer with wings spread wide, purple-gray fur, tiny fangs, two glowing pale eyes."),
    ("enemy_caster", "enemy", 28, 28, S + "enemy_caster.png", [], "A hooded cultist caster in tattered dark violet robes, face hidden in shadow except two glowing eyes, holding a short crooked staff topped with a glowing violet orb."),
    ("enemy_dasher", "enemy", 32, 32, S + "enemy_dasher.png", [], "A wild horned shadow boar lowering its head to charge, dark brown bristly hide, two curved ivory tusks, red glowing eyes."),
    ("enemy_hound", "enemy", 36, 36, S + "enemy_hound.png", [], "A shadow hound charging toward the viewer, chunky simple body with big paws, light blue-gray fur with a pale belly and dark outline, big glowing ember-orange eyes, bared white teeth. Strong contrast, few large shapes."),
    ("enemy_splitter", "enemy", 36, 36, S + "enemy_splitter.png", [], "A large bloated moss-green slime with two smaller slime blobs visibly budding off its sides, cracked surface, two eyes."),
    ("enemy_knight", "enemy", 48, 48, S + "enemy_knight.png", [], "A hollow cursed knight in dented dark iron plate armor, a tall tower shield in front, a broken sword, an empty helmet visor with a faint violet glow inside. Heavy and slow."),
    ("enemy_miniboss", "enemy", 56, 56, S + "enemy_miniboss.png", [], "A large wraith specter in a ragged dark shroud, long clawed arms reaching forward, cold pale-cyan light glowing from inside the hood, wispy lower body with no legs."),
    ("enemy_boss", "enemy", 96, 96, S + "enemy_boss.png", [], "The Warden of the Seal, a final boss: a towering armored guardian with a horned stone crown, a cracked stone-and-iron body covered in glowing violet seal runes, holding a giant key-shaped mace, a dark seed-like crystal glowing in its chest. Accent violet #A04BE6."),
    ("icon_moon_dagger", "icon", 54, 54, S + "icon_moon_dagger.png", [], "A curved silver throwing dagger whose blade is shaped like a crescent moon, pale blue glowing edge, placed diagonally from bottom-left to top-right."),
    ("icon_spirit_orb", "icon", 54, 54, S + "icon_spirit_orb.png", [], "A glowing cyan spirit orb with a tiny swirling soul inside, two small sparks orbiting around it."),
    ("icon_fire_wisp", "icon", 54, 54, S + "icon_fire_wisp.png", [], "A small living flame wisp with two eyes, orange core and yellow tips, a few embers."),
    ("icon_thorn_ring", "icon", 54, 54, S + "icon_thorn_ring.png", [], "A ring-shaped wreath of dark green thorny vines with sharp spikes pointing outward all around."),
    ("icon_star_needle", "icon", 54, 54, S + "icon_star_needle.png", [], "A slender golden needle with a small four-pointed star at its head and a couple of tiny sparkles, placed diagonally from bottom-left to top-right."),
    ("shop_swift", "icon", 54, 54, S + "shop_swift.png", [], "A pair of leather boots with small white wings at the ankles, green accents #80D980."),
    ("shop_magnet", "icon", 54, 54, S + "shop_magnet.png", [], "A horseshoe magnet charm hanging on a cord, violet enamel #BF80F2 with silver tips, two tiny attraction sparks."),
    ("shop_heart", "icon", 54, 54, S + "shop_heart.png", [], "A red heart encased in riveted dark iron plates, a crack of red light between the plates."),
    ("shop_focus", "icon", 54, 54, S + "shop_focus.png", [], "A golden hourglass with glowing sand and a small focused eye emblem on its frame. Gold #E6B333."),
    ("shop_power", "icon", 54, 54, S + "shop_power.png", [], "A glowing hot-pink power crystal (#FF4DA6, not pure magenta) locked inside a small iron cage, energy cracks.", "green #00FF00"),
    ("pickup_xp", "icon", 24, 24, S + "pickup_xp.png", [], "A small faceted soul crystal gem, cyan-teal with a white sparkle."),
    ("pickup_gold", "icon", 24, 24, S + "pickup_gold.png", [], "A single gold coin seen exactly face-on, an embossed crescent moon in the center, bright rim highlight, perfectly symmetric."),
    ("proj_moon_dagger", "proj", 28, 12, S + "proj_moon_dagger.png", ["--height", "12"], "A silver throwing dagger with a crescent-shaped blade and pale blue edge."),
    ("proj_star_needle", "proj", 24, 8, S + "proj_star_needle.png", ["--height", "8"], "A thin golden needle with a tiny star at its back end."),
    ("proj_thorn", "proj", 20, 10, S + "proj_thorn.png", ["--height", "10"], "A single sharp dark-green thorn spike."),
    ("proj_spirit_orb", "icon", 24, 24, S + "proj_spirit_orb.png", [], "A round glowing cyan spirit orb with a bright white core (perfectly round, no direction)."),
    ("proj_enemy", "icon", 20, 20, S + "proj_enemy.png", [], "A round cursed energy bolt in white and light gray only (it is color-tinted in the engine), a small inner swirl, dark outline, perfectly round."),
    ("ground_tile", "tile", 64, 64, S + "ground_tile.png", ["--mode", "tile", "--desaturate", "1"], "Packed ancient earth with small pebbles and faint cracks."),
    ("ground_tile_b", "tile", 64, 64, S + "ground_tile_b.png", ["--mode", "tile", "--desaturate", "1"], "Packed ancient earth with small pebbles, plus two worn flat flagstones partly sunk in it."),
    ("ground_tile_c", "tile", 64, 64, S + "ground_tile_c.png", ["--mode", "tile", "--desaturate", "1"], "Packed ancient earth with small pebbles, plus sparse short grass tufts and thin roots."),
    ("decor_rock", "enemy", 48, 48, S + "decor_rock.png", ["--desaturate", "1"], "Not a monster: a cluster of two weathered boulders with a little moss, three-quarter top-down view, neutral gray stone."),
    ("decor_torch", "enemy", 48, 48, S + "decor_torch.png", [], "Not a monster: a standing iron brazier on a short post with a small bright yellow-orange flame, three-quarter top-down view, dark iron."),
    ("icon_hud_joystick_base", "ui", 128, 128, U + "icon_hud/icon_hud_joystick_base.png", [], "Virtual joystick base: a flat circular dark-navy disc, thin pale-silver rim, four tiny arrow notches at up/down/left/right, subtle inner ring. Perfect circle seen from above."),
    ("icon_hud_joystick_thumb", "ui", 52, 52, U + "icon_hud/icon_hud_joystick_thumb.png", [], "Joystick thumb knob: a round pale moonlight-silver button seen from above, soft bevel, small ember-gold dot in the center. Perfect circle."),
    ("icon_hud_timer", "ui", 44, 44, U + "icon_hud/icon_hud_timer.png", [], "A small round pocket watch, dark navy frame, pale moonlight face, two silver hands, no numbers."),
    ("icon_hud_kills", "ui", 40, 40, U + "icon_hud/icon_hud_kills.png", [], "A small pale bone skull with crossed bones behind it."),
    ("icon_reward_coins", "ui", 48, 48, U + "icon_reward/icon_reward_coins.png", [], "A small stack of three gold coins with a fourth coin leaning in front, crescent-moon emboss, bright rim highlight."),
]


def prompt_for(a):
    name, tpl, n, h, _, _, subject, *bg = a
    body = TEMPLATES[tpl].format(n=n, h=h)
    tail = BG.format(bg=(bg[0] if bg else "magenta #FF00FF")) if tpl != "tile" else "- Square image.\n"
    return HEAD + body + (COMMON if tpl != "tile" else "") + f"- Subject: {subject}\n" + tail


def codex_command() -> list[str]:
    codex = shutil.which("codex")
    if codex is None:
        raise SystemExit("error: codex CLI not found on PATH (npm i -g @openai/codex, then codex login).")
    # On Windows the npm shim is a .cmd that would push the multi-line prompt through
    # cmd.exe; call the JS entry through node instead when it is there.
    entry = Path(codex).parent / "node_modules" / "@openai" / "codex" / "bin" / "codex.js"
    node = shutil.which("node")
    return [node, str(entry)] if entry.exists() and node else [codex]


def generate(asset, codex: list[str]) -> tuple[str, str]:
    name = asset[0]
    prompt = prompt_for(asset)
    (ART / "prompts" / f"{name}.txt").write_text(prompt, encoding="utf-8")
    for attempt in (1, 2):
        log = ART / "logs" / f"{name}_{attempt}.log"
        with open(log, "w", encoding="utf-8") as fh:
            try:
                subprocess.run([*codex, "exec", "--skip-git-repo-check", "-s", "read-only", "-C", str(ART), prompt],
                               stdin=subprocess.DEVNULL, stdout=fh, stderr=subprocess.STDOUT, timeout=CODEX_TIMEOUT_S)
            except subprocess.TimeoutExpired:
                fh.write("\n[codex_generate_sprites] timeout\n")
        m = re.search(r"session id:\s*(\S+)", log.read_text(encoding="utf-8", errors="replace"))
        pngs = sorted((GEN_DIR / m.group(1)).glob("*.png")) if m else []
        if pngs:
            shutil.copyfile(pngs[-1], ART / "raw" / f"{name}.png")
            return name, f"generated (attempt {attempt})"
    return name, f"FAILED - see {ART / 'logs'}"


def apply(asset) -> tuple[str, str]:
    name, _, n, _, path, extra = asset[:6]
    cmd = [sys.executable, str(REPO_ROOT / "scripts" / "pixelize_sprite.py"), str(ART / "raw" / f"{name}.png"),
           str(REPO_ROOT / path), "--size", str(n), "--preview", str(ART / "preview" / f"{name}.png"), "--force", *extra]
    r = subprocess.run(cmd, capture_output=True, text=True)
    lines = [l.strip() for l in (r.stdout + r.stderr).splitlines()[1:] if "preview:" not in l]
    return name, ("ok: " if r.returncode == 0 else "FAILED: ") + " | ".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("names", nargs="*", help="asset names (default: all)")
    parser.add_argument("--regen", action="store_true", help="redraw even if art/raw/<name>.png exists")
    parser.add_argument("--no-apply", action="store_true", help="only generate raw images")
    args = parser.parse_args()
    known = {a[0]: a for a in ASSETS}
    unknown = [n for n in args.names if n not in known]
    if unknown:
        parser.error(f"unknown asset(s): {', '.join(unknown)}. Known: {', '.join(known)}")
    selected = [known[n] for n in args.names] if args.names else list(ASSETS)
    for d in ("raw", "prompts", "logs", "preview"):
        (ART / d).mkdir(parents=True, exist_ok=True)

    todo = [a for a in selected if args.regen or not (ART / "raw" / f"{a[0]}.png").exists()]
    if todo:
        codex = codex_command()
        print(f"generating {len(todo)} image(s) with Codex, {PARALLEL} at a time", flush=True)
        with ThreadPoolExecutor(PARALLEL) as ex:
            for name, status in ex.map(lambda a: generate(a, codex), todo):
                print(f"  {name}: {status}", flush=True)
    if args.no_apply:
        return 0
    failed = 0
    for a in selected:
        if not (ART / "raw" / f"{a[0]}.png").exists():
            print(f"  {a[0]}: skipped (no raw image)")
            failed += 1
            continue
        name, status = apply(a)
        failed += status.startswith("FAILED")
        print(f"  {name}: {status}", flush=True)
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
