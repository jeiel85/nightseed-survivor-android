extends Control

## Story replay screen. Lists every stage with its unlocked dialogue lines
## (intro / boss intro / clear). Locked stages show a "coming soon" placeholder
## so players see what's still to come without spoiling the dialogue itself.

const COLOR_MIDNIGHT := Color(0.059, 0.067, 0.083, 1.0) # #0F1115
const COLOR_MIDNIGHT_DEEP := Color(0.025, 0.030, 0.045, 1.0)
const COLOR_PARCHMENT := Color(0.949, 0.922, 0.863, 1.0) # #F2EBDC
const COLOR_PARCHMENT_EDGE := Color(0.753, 0.647, 0.420, 1.0)
const COLOR_INK := Color(0.173, 0.141, 0.122, 1.0)
const COLOR_INK_FADED := Color(0.173, 0.141, 0.122, 0.68)
const COLOR_GOLD := Color(0.831, 0.686, 0.216, 1.0) # #D4AF37
const COLOR_LOCKED_SURFACE := Color(0.165, 0.176, 0.208, 0.95) # #2A2D35
const COLOR_LOCKED_TEXT := Color(0.57, 0.60, 0.67, 0.88)
const CARD_WIDTH := 656.0
const STORY_PARCHMENT_PATH := "res://assets/sprites/ui/story/panel_story_parchment.9.png"
const STORY_LOCKED_PATH := "res://assets/sprites/ui/story/panel_story_locked.9.png"
const STORY_DIVIDER_PATH := "res://assets/sprites/ui/story/divider_story_diamond.png"
const STORY_LOCK_ICON_PATH := "res://assets/sprites/ui/story/icon_story_lock.png"
const STORY_PANEL_MARGIN := 24

@onready var title_label: Label = $VBox/HeaderRow/Title
@onready var hint_label: Label = $VBox/Hint
@onready var stage_list: VBoxContainer = $VBox/ScrollContainer/StageList
@onready var btn_codex: Button = $VBox/HeaderRow/BtnCodex
@onready var btn_back: Button = $VBox/BtnBack

func _ready() -> void:
	AudioManager.play_bgm("menu")
	queue_redraw()
	_apply_button_styles()
	btn_back.pressed.connect(_on_back_pressed)
	btn_codex.pressed.connect(_on_codex_pressed)
	if Localization:
		Localization.language_changed.connect(_on_language_changed)
	_refresh()

func _apply_button_styles() -> void:
	ButtonStyles.apply_stone_secondary(btn_back, Color(0.55, 0.36, 0.20, 1.0))
	ButtonStyles.apply_stone_secondary(btn_codex, COLOR_GOLD)

func _refresh() -> void:
	title_label.text = Localization.tr_key("story_title")
	hint_label.text = Localization.tr_key("story_hint")
	btn_codex.text = Localization.tr_key("btn_to_codex")
	btn_back.text = Localization.tr_key("btn_back_to_menu")
	_rebuild_list()

func _rebuild_list() -> void:
	for child in stage_list.get_children():
		child.queue_free()
	if Stages == null:
		return
	for stage in Stages.stages:
		if not (stage is Dictionary):
			continue
		var stage_id: String = String(stage.get("id", ""))
		if stage_id.is_empty():
			continue
		stage_list.add_child(_build_stage_entry(stage_id))

func _build_stage_entry(stage_id: String) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _entry_style(stage_id))
	panel.custom_minimum_size.x = CARD_WIDTH
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 9)
	panel.add_child(vbox)

	var unlocked: bool = (GameData != null and GameData.is_stage_unlocked(stage_id))
	_add_card_header(vbox, stage_id, unlocked)
	if not unlocked:
		_add_locked_body(vbox)
		return panel

	_append_section(vbox, stage_id, "intro", "story_section_intro")
	_append_section(vbox, stage_id, "boss_intro", "story_section_boss")
	_append_section(vbox, stage_id, "clear", "story_section_clear")
	return panel

func _add_card_header(vbox: VBoxContainer, stage_id: String, unlocked: bool) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	vbox.add_child(row)

	var title_box := VBoxContainer.new()
	title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_box.add_theme_constant_override("separation", 2)
	row.add_child(title_box)

	var chapter := Label.new()
	chapter.text = _chapter_label(stage_id)
	chapter.add_theme_font_size_override("font_size", 13)
	chapter.add_theme_color_override("font_color", COLOR_INK_FADED if unlocked else COLOR_LOCKED_TEXT)
	chapter.add_theme_constant_override("outline_size", 0)
	title_box.add_child(chapter)

	var name_label := Label.new()
	name_label.text = Stages.display_name(stage_id) if Stages.has_method("display_name") else stage_id
	name_label.add_theme_font_size_override("font_size", 28)
	name_label.add_theme_color_override("font_color", COLOR_INK if unlocked else Color(0.50, 0.52, 0.58, 1.0))
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_box.add_child(name_label)

	var seal := Label.new()
	seal.custom_minimum_size = Vector2(44, 44)
	seal.text = _stage_icon(stage_id)
	seal.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	seal.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	seal.add_theme_font_size_override("font_size", 24)
	seal.add_theme_color_override("font_color", _stage_accent(stage_id).lightened(0.12) if unlocked else Color(0.34, 0.35, 0.40, 1.0))
	row.add_child(seal)

	_add_rule(vbox, _stage_accent(stage_id) if unlocked else Color(0.33, 0.34, 0.40, 1.0))

func _add_locked_body(vbox: VBoxContainer) -> void:
	var lock_texture := _try_load_texture(STORY_LOCK_ICON_PATH)
	if lock_texture != null:
		var icon := TextureRect.new()
		icon.texture = lock_texture
		icon.custom_minimum_size = Vector2(88, 88)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		vbox.add_child(icon)

	var lock_label := Label.new()
	lock_label.text = "LOCKED"
	lock_label.custom_minimum_size = Vector2(0, 40 if lock_texture != null else 58)
	lock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lock_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lock_label.add_theme_font_size_override("font_size", 30)
	lock_label.add_theme_color_override("font_color", Color(0.46, 0.47, 0.52, 0.92))
	lock_label.add_theme_constant_override("outline_size", 4)
	lock_label.add_theme_color_override("font_outline_color", Color(0.05, 0.05, 0.07, 0.95))
	vbox.add_child(lock_label)

	var locked := Label.new()
	locked.text = Localization.tr_key("story_locked_long")
	locked.add_theme_font_size_override("font_size", 20)
	locked.add_theme_color_override("font_color", COLOR_LOCKED_TEXT)
	locked.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	locked.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(locked)

func _append_section(vbox: VBoxContainer, stage_id: String, slot: String, header_key: String) -> void:
	var lines: Array = Story.get_stage_lines(stage_id, slot) if Story else []
	if lines.is_empty():
		return
	var header := Label.new()
	header.text = _section_label(header_key)
	header.add_theme_font_size_override("font_size", 14)
	header.add_theme_color_override("font_color", _stage_accent(stage_id).darkened(0.22))
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(header)
	for entry in lines:
		if not (entry is Dictionary):
			continue
		var line := Label.new()
		var speaker: String = String(entry.get("speaker", ""))
		var text: String = String(entry.get("text", ""))
		line.text = ("%s - %s" % [speaker, text]) if speaker != "" else text
		line.add_theme_font_size_override("font_size", 21)
		line.add_theme_color_override("font_color", COLOR_INK)
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vbox.add_child(line)
	_add_rule(vbox, _stage_accent(stage_id))

func _entry_style(stage_id: String) -> StyleBox:
	var unlocked: bool = (GameData != null and GameData.is_stage_unlocked(stage_id))
	var texture_path := STORY_PARCHMENT_PATH if unlocked else STORY_LOCKED_PATH
	var texture := _try_load_texture(texture_path)
	if texture != null:
		return _entry_texture_style(texture)

	var sb := StyleBoxFlat.new()
	if unlocked:
		sb.bg_color = COLOR_PARCHMENT
		sb.border_color = COLOR_GOLD
	else:
		sb.bg_color = COLOR_LOCKED_SURFACE
		sb.border_color = Color(0.29, 0.30, 0.36, 0.92)
	sb.set_border_width_all(3 if unlocked else 2)
	sb.border_width_top = 5 if unlocked else 2
	sb.border_width_bottom = 5 if unlocked else 2
	sb.set_corner_radius_all(4)
	sb.content_margin_left = 22
	sb.content_margin_right = 22
	sb.content_margin_top = 18
	sb.content_margin_bottom = 20
	sb.shadow_color = Color(0, 0, 0, 0.42)
	sb.shadow_size = 10
	return sb

func _entry_texture_style(texture: Texture2D) -> StyleBoxTexture:
	var sb := StyleBoxTexture.new()
	sb.texture = texture
	sb.texture_margin_left = STORY_PANEL_MARGIN
	sb.texture_margin_right = STORY_PANEL_MARGIN
	sb.texture_margin_top = STORY_PANEL_MARGIN
	sb.texture_margin_bottom = STORY_PANEL_MARGIN
	sb.content_margin_left = 28
	sb.content_margin_right = 28
	sb.content_margin_top = 24
	sb.content_margin_bottom = 26
	return sb

func _add_rule(vbox: VBoxContainer, accent: Color) -> void:
	var divider_texture := _try_load_texture(STORY_DIVIDER_PATH)
	if divider_texture != null:
		var divider := TextureRect.new()
		divider.texture = divider_texture
		divider.custom_minimum_size = Vector2(0, 24)
		divider.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		divider.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		divider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.add_child(divider)
		return

	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 18)
	row.add_theme_constant_override("separation", 8)
	vbox.add_child(row)

	var left := ColorRect.new()
	left.color = Color(accent.r, accent.g, accent.b, 0.30)
	left.custom_minimum_size.y = 1
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(left)

	var node := Label.new()
	node.text = "◆"
	node.add_theme_font_size_override("font_size", 13)
	node.add_theme_color_override("font_color", Color(accent.r, accent.g, accent.b, 0.72))
	node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(node)

	var right := ColorRect.new()
	right.color = Color(accent.r, accent.g, accent.b, 0.30)
	right.custom_minimum_size.y = 1
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(right)

func _chapter_label(stage_id: String) -> String:
	var ids := []
	var stage_source: Array = Stages.stages if Stages else []
	for stage in stage_source:
		if stage is Dictionary:
			ids.append(String(stage.get("id", "")))
	var index := ids.find(stage_id)
	if index < 0:
		index = 0
	return "CHAPTER %02d" % (index + 1)

func _section_label(header_key: String) -> String:
	return Localization.tr_key(header_key).replace("—", "").strip_edges().to_upper()

func _stage_accent(stage_id: String) -> Color:
	var stage := Stages.get_stage(stage_id) if Stages else {}
	var color_text := String(stage.get("color", ""))
	if color_text.begins_with("#") and color_text.length() == 7:
		return Color.html(color_text)
	match stage_id:
		"forest":
			return Color(0.176, 0.353, 0.153, 1.0)
		"frozen_wastes":
			return Color(0.455, 0.667, 0.800, 1.0)
		"twilight_sanctum":
			return Color(0.667, 0.467, 1.000, 1.0)
		"inferno_chasm":
			return Color(0.769, 0.302, 0.169, 1.0)
		"cursed_tomb":
			return Color(0.867, 0.267, 0.533, 1.0)
		_:
			return COLOR_GOLD

func _stage_icon(stage_id: String) -> String:
	match stage_id:
		"forest":
			return "♣"
		"frozen_wastes":
			return "*"
		"twilight_sanctum":
			return "✦"
		"inferno_chasm":
			return "▲"
		"cursed_tomb":
			return "✧"
		_:
			return "◇"

func _try_load_texture(path: String) -> Texture2D:
	if not ResourceLoader.exists(path):
		return null
	var res := load(path)
	if res is Texture2D:
		return res
	return null

func _on_language_changed(_lang: String) -> void:
	_refresh()

func _on_back_pressed() -> void:
	Transition.change_scene("res://scenes/ui/MainMenu.tscn")

func _on_codex_pressed() -> void:
	Transition.change_scene("res://scenes/ui/CodexUI.tscn")

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST or what == NOTIFICATION_WM_CLOSE_REQUEST:
		_on_back_pressed()

func _draw() -> void:
	var rect := get_rect()
	draw_rect(Rect2(Vector2.ZERO, rect.size), COLOR_MIDNIGHT, true)
	var center := Vector2(rect.size.x * 0.52, rect.size.y * 0.18)
	for i in range(9, 0, -1):
		var radius := rect.size.x * (0.12 + float(i) * 0.055)
		var alpha := 0.010 + float(10 - i) * 0.006
		draw_circle(center, radius, Color(COLOR_GOLD.r, COLOR_GOLD.g, COLOR_GOLD.b, alpha))
	for i in range(0, 44):
		var x := fmod(float(i * 97), max(rect.size.x, 1.0))
		var y := fmod(float(i * 53), max(rect.size.y, 1.0))
		var a := 0.018 + float(i % 5) * 0.006
		draw_rect(Rect2(Vector2(x, y), Vector2(1, 1)), Color(1, 1, 1, a), true)
	draw_rect(Rect2(Vector2(0, rect.size.y * 0.78), Vector2(rect.size.x, rect.size.y * 0.22)), Color(COLOR_MIDNIGHT_DEEP.r, COLOR_MIDNIGHT_DEEP.g, COLOR_MIDNIGHT_DEEP.b, 0.52), true)
