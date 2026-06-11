class_name UIKit
extends RefCounted

## Shared chrome for the sub-screens (Shop / CharacterSelect / StageSelect /
## Settings …) so every screen reads as the same game: night-sky backdrop,
## memory-gold title, stone-tablet cards, one selected-glow treatment.
## All texture loads fall back gracefully (fresh checkout before import pass).

const BG_PATH := "res://assets/sprites/ui/bg/bg_menu_night_sky.png"
const PANEL_CARD_DARK_PATH := "res://assets/sprites/ui/panel/panel_card_dark.9.png"
const GLOW_GOLD_PATH := "res://assets/sprites/ui/panel/frame_card_glow_gold.9.png"

# 단일 강조 팔레트 — 화면마다 제각각이던 무지개 텍스트를 정리한다.
const TITLE_GOLD := Color(0.949, 0.847, 0.580)        # 기억의 금색 (제목/보상)
const TEXT_PRIMARY := Color(0.910, 0.940, 1.000)      # 본문 (살짝 푸른 흰색)
const TEXT_MUTED := Color(0.640, 0.690, 0.790)        # 보조 설명
const OUTLINE_NAVY := Color(0.043, 0.078, 0.149, 0.9)

static func apply_screen_chrome(screen: Control, title: Label, back_btn: Button) -> void:
	_add_backdrop(screen)
	if title != null:
		title.add_theme_color_override("font_color", TITLE_GOLD)
		title.add_theme_color_override("font_outline_color", OUTLINE_NAVY)
		title.add_theme_constant_override("outline_size", 5)
	if back_btn != null:
		ButtonStyles.apply_stone_texture(back_btn, ButtonStyles.STONE_BORDER)

static func _add_backdrop(screen: Control) -> void:
	if screen.get_node_or_null("UIKitBackdrop") != null:
		return
	if not ResourceLoader.exists(BG_PATH):
		return
	var tex := load(BG_PATH)
	if not (tex is Texture2D):
		return
	var bg := TextureRect.new()
	bg.name = "UIKitBackdrop"
	bg.texture = tex
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	# Dimmed hard so list text keeps contrast; the point is "night sky",
	# not a poster behind the content.
	bg.modulate = Color(0.42, 0.44, 0.55, 1.0)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	screen.add_child(bg)
	screen.move_child(bg, 0)

# Stone tablet card — same texture/margin spec as the LevelUpUI cards so the
# whole game shares one card language. `accent` bleeds in very subtly.
static func card_style(accent: Color = Color(0.55, 0.62, 0.78)) -> StyleBox:
	if ResourceLoader.exists(PANEL_CARD_DARK_PATH):
		var tex := load(PANEL_CARD_DARK_PATH)
		if tex is Texture2D:
			var sb := StyleBoxTexture.new()
			sb.texture = tex
			sb.texture_margin_left = 14
			sb.texture_margin_right = 14
			sb.texture_margin_top = 14
			sb.texture_margin_bottom = 14
			sb.content_margin_left = 16
			sb.content_margin_right = 16
			sb.content_margin_top = 12
			sb.content_margin_bottom = 12
			sb.modulate_color = Color(1, 1, 1, 1).lerp(accent, 0.10)
			return sb
	var sb_flat := StyleBoxFlat.new()
	sb_flat.bg_color = Color(0.078, 0.094, 0.137, 0.92)
	sb_flat.border_color = accent.darkened(0.10)
	sb_flat.set_border_width_all(2)
	sb_flat.set_corner_radius_all(6)
	sb_flat.set_content_margin_all(12)
	return sb_flat

# Gold glow overlay marking the selected card (same look as the level-up
# "upgrade" rarity frame). Pass on=false to remove.
static func set_card_glow(card: PanelContainer, on: bool) -> void:
	var glow: NinePatchRect = card.get_node_or_null("UIKitGlow") as NinePatchRect
	if not on:
		if glow != null:
			glow.visible = false
		return
	if not ResourceLoader.exists(GLOW_GOLD_PATH):
		return
	if glow == null:
		glow = NinePatchRect.new()
		glow.name = "UIKitGlow"
		glow.set_anchors_preset(Control.PRESET_FULL_RECT)
		glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		glow.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		glow.draw_center = false
		glow.patch_margin_left = 24
		glow.patch_margin_right = 24
		glow.patch_margin_top = 24
		glow.patch_margin_bottom = 24
		card.add_child(glow)
		card.move_child(glow, card.get_child_count() - 1)
	glow.texture = load(GLOW_GOLD_PATH)
	glow.self_modulate = Color.WHITE
	glow.visible = true
