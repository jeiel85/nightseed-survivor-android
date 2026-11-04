class_name SpriteArt
extends RefCounted

## Sizing rules for battlefield sprites while the art moves from the 16px Kenney
## tiles to sprites authored at their on-screen size (docs/SPRITE_REGEN_32PX.md).
##
## Callers say how wide a sprite should look, not a stretch factor. A 16px legacy
## texture keeps its old stretch; a redrawn texture already within SNAP_TOLERANCE
## of that width is drawn 1:1, so every texel on the battlefield is the same size.

const LEGACY_SIZE := 16
const SNAP_TOLERANCE := 0.15

static func is_legacy(tex: Texture2D) -> bool:
	return tex != null and tex.get_width() <= LEGACY_SIZE

## Uniform scale that makes `tex` appear `display_px` wide.
static func scale_for(tex: Texture2D, display_px: float) -> float:
	if tex == null or tex.get_width() <= 0:
		return 1.0
	var s: float = display_px / float(tex.get_width())
	if not is_legacy(tex) and absf(s - 1.0) <= SNAP_TOLERANCE:
		return 1.0
	return s

## The dedicated texture when it has been drawn, otherwise the shared legacy one
## (e.g. a projectile still borrowing its weapon icon).
static func load_or(path: String, fallback: Texture2D) -> Texture2D:
	if ResourceLoader.exists(path):
		var tex := load(path) as Texture2D
		if tex != null:
			return tex
	return fallback
