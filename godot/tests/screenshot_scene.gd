extends SceneTree

## Dev helper: loads an arbitrary scene and saves a viewport screenshot to the
## OS temp dir. Autoloads are available, so most UI scenes render standalone.
## Run: godot --path godot --resolution 540x960 -s tests/screenshot_scene.gd -- res://scenes/ui/ShopUI.tscn [out_name]

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.is_empty():
		printerr("usage: -- <scene_path> [out_name]")
		quit(1)
		return
	var scene_path := args[0]
	var out_name := args[1] if args.size() >= 2 else scene_path.get_file().get_basename()
	change_scene_to_file(scene_path)
	_run(out_name)

func _run(out_name: String) -> void:
	await create_timer(2.5).timeout
	var out_dir := OS.get_environment("TEMP").replace("\\", "/")
	if out_dir == "":
		out_dir = "user://"
	var path := out_dir + "/ns_" + out_name + ".png"
	root.get_texture().get_image().save_png(path)
	print("SCREENSHOT: " + path)
	quit(0)
