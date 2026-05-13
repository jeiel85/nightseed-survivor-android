extends RefCounted
class_name ButtonStyles

# Menu/result button color palette — applied at runtime via add_theme_stylebox_override.
# Tuned for the dark game background; each entry is the "normal" tone, hover lightens, pressed darkens.
const PLAY        := Color(0.86, 0.55, 0.20)   # warm amber — primary action
const CHARACTER   := Color(0.20, 0.55, 0.72)   # teal
const STAGE       := Color(0.58, 0.40, 0.22)   # earth/brass
const SHOP        := Color(0.22, 0.62, 0.36)   # green
const DIFFICULTY  := Color(0.52, 0.30, 0.72)   # violet
const LEADERBOARD := Color(0.78, 0.62, 0.20)   # gold (★)
const CODEX       := Color(0.30, 0.36, 0.72)   # indigo
const LANGUAGE    := Color(0.34, 0.42, 0.52)   # slate
const CREDITS     := Color(0.26, 0.26, 0.34)   # graphite
const VICTORY     := Color(0.86, 0.55, 0.20)   # amber (=PLAY)
const DEFEAT      := Color(0.82, 0.32, 0.32)   # red
const NEUTRAL     := Color(0.34, 0.42, 0.52)   # slate (back-to-menu, secondary)

static func apply(button: Button, base: Color) -> void:
	button.add_theme_stylebox_override("normal",   _box(base, 0.0))
	button.add_theme_stylebox_override("hover",    _box(base, 0.16))
	button.add_theme_stylebox_override("pressed",  _box(base, -0.20))
	button.add_theme_stylebox_override("focus",    _focus_box(base))
	button.add_theme_stylebox_override("disabled", _box(base.darkened(0.45), 0.0))
	button.add_theme_color_override("font_color", Color(1, 1, 1))
	button.add_theme_color_override("font_hover_color", Color(1, 1, 1))
	button.add_theme_color_override("font_pressed_color", Color(0.95, 0.95, 0.95))
	button.add_theme_color_override("font_focus_color", Color(1, 1, 1))

static func _box(base: Color, shift: float) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	var c := base
	if shift > 0.0:
		c = c.lightened(shift)
	elif shift < 0.0:
		c = c.darkened(-shift)
	sb.bg_color = c
	sb.set_corner_radius_all(10)
	sb.set_border_width_all(2)
	sb.border_color = base.lightened(0.35)
	sb.content_margin_left = 14
	sb.content_margin_right = 14
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	return sb

static func _focus_box(base: Color) -> StyleBoxFlat:
	var sb := _box(base, 0.0)
	sb.border_color = Color(1, 1, 1, 0.85)
	sb.set_border_width_all(3)
	return sb
