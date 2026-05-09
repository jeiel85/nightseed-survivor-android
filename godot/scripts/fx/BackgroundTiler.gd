extends Node2D
class_name BackgroundTiler

## Procedural ground for the survival arena.
## - Base tile drawn at chunk grid, but with per-tile hash-driven
##   color tint + flip → the obvious grid pattern dissolves.
## - Decorative scatter (pebbles, fireflies) placed at deterministic
##   world positions per chunk so they appear to belong to the world,
##   not redraw each frame.
## - All draws are world-space; the camera follows the player and the
##   scenery scrolls naturally.

@export var tile_texture: Texture2D
@export var tile_modulate: Color = Color(0.42, 0.36, 0.55, 1.0)
@export var tile_size_px: float = 64.0
@export var follow_target_path: NodePath
@export var pebble_color_a: Color = Color(0.68, 0.62, 0.78, 0.55)
@export var pebble_color_b: Color = Color(0.30, 0.24, 0.42, 0.55)
@export var firefly_color: Color = Color(0.80, 0.95, 1.0, 0.9)

var _target: Node2D

const CHUNK_PX: float = 256.0
const HASH_X: int = 73856093
const HASH_Y: int = 19349663

func _ready() -> void:
	z_index = -5
	if not follow_target_path.is_empty():
		_target = get_node_or_null(follow_target_path)

func _process(_delta: float) -> void:
	queue_redraw()

func _hash(ix: int, iy: int) -> int:
	return ((ix * HASH_X) ^ (iy * HASH_Y)) & 0x7FFFFFFF

func _draw() -> void:
	var center: Vector2 = _target.global_position if is_instance_valid(_target) else Vector2.ZERO
	var view: Vector2 = get_viewport_rect().size
	if view.x <= 0 or view.y <= 0:
		view = Vector2(720, 1280)
	var half: Vector2 = view * 0.6 + Vector2(CHUNK_PX, CHUNK_PX)
	var min_p := center - half
	var max_p := center + half

	# 1) Tile fill with per-tile color variation + horizontal flip variation.
	if tile_texture:
		var src_rect := Rect2(Vector2.ZERO, tile_texture.get_size())
		var sx: float = floor(min_p.x / tile_size_px) * tile_size_px
		var sy: float = floor(min_p.y / tile_size_px) * tile_size_px
		var x: float = sx
		while x < max_p.x:
			var y: float = sy
			while y < max_p.y:
				var ix: int = int(round(x / tile_size_px))
				var iy: int = int(round(y / tile_size_px))
				var h: int = _hash(ix, iy)
				var v: float = float(h % 1000) / 1000.0
				var tint: Color = tile_modulate.lerp(tile_modulate * 1.45, v * 0.7)
				tint.a = 1.0
				var dst_rect := Rect2(Vector2(x, y), Vector2(tile_size_px, tile_size_px))
				# Horizontal flip on every other tile (using a different bit) to break the pattern
				if (h >> 8) & 1:
					var flipped_src := Rect2(Vector2(src_rect.size.x, 0), Vector2(-src_rect.size.x, src_rect.size.y))
					draw_texture_rect_region(tile_texture, dst_rect, flipped_src, tint)
				else:
					draw_texture_rect_region(tile_texture, dst_rect, src_rect, tint)
				y += tile_size_px
			x += tile_size_px

	# 2) Decorative scatter — pebbles per chunk
	var csx: float = floor(min_p.x / CHUNK_PX) * CHUNK_PX
	var csy: float = floor(min_p.y / CHUNK_PX) * CHUNK_PX
	var cx: float = csx
	while cx < max_p.x:
		var cy: float = csy
		while cy < max_p.y:
			var cix: int = int(round(cx / CHUNK_PX))
			var ciy: int = int(round(cy / CHUNK_PX))
			var seed: int = _hash(cix, ciy)
			var rng := RandomNumberGenerator.new()
			rng.seed = seed
			# 4-7 pebbles per chunk
			var n: int = rng.randi_range(4, 7)
			for i in range(n):
				var px: float = cx + rng.randf_range(8.0, CHUNK_PX - 8.0)
				var py: float = cy + rng.randf_range(8.0, CHUNK_PX - 8.0)
				var rr: float = rng.randf_range(2.0, 5.0)
				var t: float = rng.randf()
				var col: Color = pebble_color_a.lerp(pebble_color_b, t)
				# Soft pebble: solid + slight outline
				draw_circle(Vector2(px, py), rr + 1.0, Color(col.r, col.g, col.b, 0.25))
				draw_circle(Vector2(px, py), rr, col)
			# 0-2 fireflies per chunk for atmosphere
			var f: int = rng.randi_range(0, 2)
			for j in range(f):
				var fx: float = cx + rng.randf_range(0.0, CHUNK_PX)
				var fy: float = cy + rng.randf_range(0.0, CHUNK_PX)
				var glow_r: float = rng.randf_range(8.0, 14.0)
				var c1: Color = firefly_color
				c1.a = 0.10
				draw_circle(Vector2(fx, fy), glow_r, c1)
				var c2: Color = firefly_color
				c2.a = 0.45
				draw_circle(Vector2(fx, fy), 2.5, c2)
			cy += CHUNK_PX
		cx += CHUNK_PX
