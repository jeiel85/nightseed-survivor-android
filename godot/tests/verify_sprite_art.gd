extends SceneTree

## Headless check for SpriteArt sizing (docs/SPRITE_REGEN_32PX.md):
##  - 16px legacy textures keep exactly the old stretch factors,
##  - every planned redraw canvas lands on 1:1 (no resampled pixels),
##  - dedicated projectile textures fall back to the legacy shared ones.
## Run: godot --headless --path godot -s tests/verify_sprite_art.gd

const PLAYER_PX := 32.0
const PICKUP_PX := 25.6

# Scene -> planned redraw canvas width (docs/SPRITE_REGEN_32PX.md §4.2).
const ENEMY_CANVAS := {
	"res://scenes/enemies/EnemySlime.tscn": 28,
	"res://scenes/enemies/EnemyBat.tscn": 24,
	"res://scenes/enemies/EnemyCaster.tscn": 28,
	"res://scenes/enemies/EnemyDasher.tscn": 32,
	"res://scenes/enemies/EnemyHound.tscn": 36,
	"res://scenes/enemies/EnemySplitter.tscn": 36,
	"res://scenes/enemies/EnemyKnight.tscn": 48,
	"res://scenes/enemies/EnemyMiniBoss.tscn": 56,
	"res://scenes/enemies/EnemyBoss.tscn": 96,
}

# [display px used in code, planned canvas width] for the non-enemy sprites.
const OTHER_CANVAS := {
	"player": [PLAYER_PX, 32],
	"pickup": [PICKUP_PX, 24],
	"proj_moon_dagger": [28.8, 28],
	"proj_star_needle": [24.0, 24],
	"proj_thorn": [20.8, 20],
	"proj_spirit_orb": [25.6, 24],
	"proj_enemy": [22.4, 20],
	"decor_largest": [54.4, 48],
}

var _failures: Array = []

func _initialize() -> void:
	_check_legacy_factors()
	_check_enemy_canvases()
	_check_other_canvases()
	_check_fallbacks()
	if _failures.is_empty():
		print("verify_sprite_art: OK")
	else:
		for f in _failures:
			printerr(f)
	quit(0 if _failures.is_empty() else 1)

func _tex(w: int, h: int = -1) -> Texture2D:
	return ImageTexture.create_from_image(Image.create(w, h if h > 0 else w, false, Image.FORMAT_RGBA8))

func _expect(label: String, got: float, want: float) -> void:
	if absf(got - want) > 0.0001:
		_failures.append("%s: scale %.4f, expected %.4f" % [label, got, want])

func _check_legacy_factors() -> void:
	var t16 := _tex(16)
	_expect("legacy player", SpriteArt.scale_for(t16, PLAYER_PX), 2.0)
	_expect("legacy pickup", SpriteArt.scale_for(t16, PICKUP_PX), 1.6)
	_expect("legacy dagger", SpriteArt.scale_for(t16, 28.8), 1.8)
	_expect("legacy needle", SpriteArt.scale_for(t16, 24.0), 1.5)
	_expect("legacy thorn", SpriteArt.scale_for(t16, 20.8), 1.3)
	_expect("legacy enemy bullet", SpriteArt.scale_for(t16, 22.4), 1.4)
	_expect("legacy decor min", SpriteArt.scale_for(t16, 38.4), 2.4)
	_expect("legacy decor max", SpriteArt.scale_for(t16, 54.4), 3.4)
	for body in [8.0, 10.0, 12.0, 40.0]:
		_expect("legacy enemy body %s" % body, SpriteArt.scale_for(t16, 16.0 * body / 7.0), body / 7.0)
	if not SpriteArt.is_legacy(t16) or SpriteArt.is_legacy(_tex(32)) or SpriteArt.is_legacy(null):
		_failures.append("is_legacy: wrong classification")
	_expect("null texture", SpriteArt.scale_for(null, 32.0), 1.0)

func _check_enemy_canvases() -> void:
	for path in ENEMY_CANVAS:
		var packed := load(path) as PackedScene
		if packed == null:
			_failures.append("LOAD FAIL: %s" % path)
			continue
		var enemy: Node = packed.instantiate()
		var display: float = 16.0 * float(enemy.get("body_size")) / 7.0
		enemy.free()
		_expect("canvas %s" % path.get_file(), SpriteArt.scale_for(_tex(int(ENEMY_CANVAS[path])), display), 1.0)
	# Splitterlings reuse the slime art at their smaller body size.
	var ling: Node = (load("res://scenes/enemies/EnemySplitterling.tscn") as PackedScene).instantiate()
	var ling_px: float = 16.0 * float(ling.get("body_size")) / 7.0
	ling.free()
	var got := SpriteArt.scale_for(_tex(28), ling_px)
	if got >= 0.9:
		_failures.append("splitterling should stay smaller than the slime, got scale %.3f" % got)

func _check_other_canvases() -> void:
	for key in OTHER_CANVAS:
		var spec: Array = OTHER_CANVAS[key]
		_expect("canvas %s" % key, SpriteArt.scale_for(_tex(int(spec[1])), float(spec[0])), 1.0)
	# Non-square projectile: width (flight direction) drives the scale.
	_expect("canvas proj 28x12", SpriteArt.scale_for(_tex(28, 12), 28.8), 1.0)

func _check_fallbacks() -> void:
	var fallback := _tex(16)
	if SpriteArt.load_or("res://assets/sprites/__missing__.png", fallback) != fallback:
		_failures.append("load_or: missing path did not return the fallback")
	var real := SpriteArt.load_or("res://assets/sprites/proj_orb.png", fallback)
	if real == fallback or real == null:
		_failures.append("load_or: existing path did not load")
