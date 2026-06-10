extends SceneTree

## Dev helper: boots GameRoot, forces the victory then defeat result panel,
## and saves viewport screenshots to the OS temp dir. Display-only — never
## calls _commit_run_results(), so local meta-progress is untouched.
## Run (windowed): godot --path godot --resolution 540x960 -s tests/screenshot_result_panel.gd

func _initialize() -> void:
	change_scene_to_file("res://scenes/main/GameRoot.tscn")
	_run()

func _run() -> void:
	await create_timer(3.0).timeout
	var out_dir := OS.get_environment("TEMP").replace("\\", "/")
	if out_dir == "":
		out_dir = "user://"
	if current_scene == null or not current_scene.has_method("_show_result"):
		printerr("SCREENSHOT: GameRoot not ready")
		quit(1)
		return
	current_scene._show_result(true)
	await create_timer(1.6).timeout
	root.get_texture().get_image().save_png(out_dir + "/ns_result_victory.png")
	current_scene._show_result(false)
	await create_timer(1.6).timeout
	root.get_texture().get_image().save_png(out_dir + "/ns_result_defeat.png")
	print("SCREENSHOT: saved to " + out_dir)
	quit(0)
