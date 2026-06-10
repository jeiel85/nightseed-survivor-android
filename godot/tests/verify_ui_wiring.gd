extends SceneTree

## Headless smoke test for the UI asset wiring pass: every reworked scene must
## instantiate, and every node path the scripts bind via @onready must exist.
## Run: godot --headless --path godot -s tests/verify_ui_wiring.gd

const CHECKS := {
	"res://scenes/main/HUD.tscn": [
		"TopBar/TimeRow/TimeLabel",
		"TopBar/TimeRow/TimeIcon",
		"TopBar/StatsRow/KillCell/KillIcon",
	],
	"res://scenes/main/GameRoot.tscn": [
		"ResultPanel/Panel/VBox/TitleWrap/Title",
		"ResultPanel/Panel/VBox/TitleWrap/TitleBanner",
		"ResultPanel/Panel/VBox/Stats",
		"ResultPanel/Panel/VBox/GoldRow/GoldIcon",
		"ResultPanel/Panel/VBox/GoldRow/GoldLabel",
	],
	"res://scenes/ui/MainMenu.tscn": [
		"VBox/TitleWrap/TitleImage",
		"VBox/TitleWrap/TitleGlow",
	],
	"res://scenes/ui/VirtualJoystick.tscn": [
		"Area",
	],
}

const TEXTURES := [
	"res://assets/sprites/ui/panel/banner_stage_clear.png",
	"res://assets/sprites/ui/icon_reward/icon_reward_coins.png",
	"res://assets/sprites/ui/icon_hud/icon_hud_timer.png",
	"res://assets/sprites/ui/icon_hud/icon_hud_kills.png",
	"res://assets/sprites/ui/icon_hud/icon_hud_joystick_base.png",
	"res://assets/sprites/ui/icon_hud/icon_hud_joystick_thumb.png",
	"res://assets/sprites/ui/icon_top/icon_settings_gear.png",
	"res://assets/sprites/ui/bg/bg_logo_glow_ornament.png",
	"res://assets/sprites/ui/story/seal_forest.png",
	"res://assets/sprites/ui/story/icon_story_book.png",
	"res://assets/sprites/ui/story/chain_story_locked.png",
]

func _initialize() -> void:
	var failures: Array = []
	for scene_path in CHECKS:
		var packed = load(scene_path)
		if packed == null or not (packed is PackedScene):
			failures.append("LOAD FAIL: %s" % scene_path)
			continue
		var inst: Node = (packed as PackedScene).instantiate()
		for node_path in CHECKS[scene_path]:
			if inst.get_node_or_null(NodePath(node_path)) == null:
				failures.append("MISSING NODE: %s :: %s" % [scene_path, node_path])
		inst.free()
	for tex_path in TEXTURES:
		var tex = load(tex_path)
		if tex == null or not (tex is Texture2D):
			failures.append("TEXTURE FAIL: %s" % tex_path)
	if failures.is_empty():
		print("VERIFY_UI_WIRING: ALL OK")
	else:
		for f in failures:
			printerr(f)
		print("VERIFY_UI_WIRING: %d FAILURE(S)" % failures.size())
	quit(0 if failures.is_empty() else 1)
