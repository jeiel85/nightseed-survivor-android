extends SceneTree

## Balance harness: runs GameRoot with NO movement input ("auto-farm" worst
## case). Level-up pauses are resolved by always picking the first card.
## Logs HP / enemy count over game-time and prints a final verdict line.
##
## Run: godot --headless --path godot -s tests/sim_afk_run.gd -- [difficulty] [timescale] [mode]
##   difficulty: normal | hard | nightmare   (default normal)
##   timescale:  float                        (default 6.0)
##   mode:       afk | kite                  (default afk)
##     afk  — no movement at all
##     kite — dumb flee bot: runs directly away from the nearest enemies,
##            models the "casual auto-farm" play the difficulty rework targets
##
## Display-only meta side effects are possible (achievements), but the run
## result is never committed (we quit before pressing Restart/Menu).
## NOTE: autoload singletons are not compile-time identifiers in -s scripts —
## access them via /root/<Name> instead.

var _last_sample_at: float = -999.0
var _mode := "afk"
var _difficulty := "normal"

func _game_data() -> Node:
	return root.get_node_or_null("/root/GameData")

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var difficulty := "normal"
	var timescale := 6.0
	if args.size() >= 1 and args[0] != "":
		difficulty = args[0]
	if args.size() >= 2:
		timescale = float(args[1])
	if args.size() >= 3:
		_mode = args[2]
	_difficulty = difficulty
	print("SIM_AFK: difficulty=%s timescale=%.1f mode=%s" % [difficulty, timescale, _mode])
	change_scene_to_file("res://scenes/main/GameRoot.tscn")
	Engine.time_scale = timescale
	_run()

func _run() -> void:
	# GameData autoload runs load_data() in _ready, which fires AFTER our
	# _initialize and would overwrite the requested difficulty with the saved
	# one. Inject after a short scaled delay (first wave spawns at ~1.5s).
	await create_timer(0.3).timeout
	var gd0 := _game_data()
	if gd0 != null:
		gd0.set("difficulty", _difficulty)
	# Poll on a real-time cadence; game-time advances time_scale× faster.
	# Short cadence so kite steering stays responsive at high time scales.
	while true:
		await create_timer(0.05).timeout
		var gr := current_scene
		var gd := _game_data()
		if gr == null or gd == null:
			continue
		# Auto-resolve the level-up pause like a lazy player: first card.
		var lui := gr.get_node_or_null("LevelUpUI")
		if lui != null and lui.visible and lui.has_method("_on_card_selected"):
			lui._on_card_selected(0)
			continue
		var player := gr.get_node_or_null("Player")
		if _mode == "kite" and player != null:
			_steer_away(player)
		var elapsed: float = float(gd.get("run_elapsed"))
		if player != null and elapsed - _last_sample_at >= 15.0:
			_last_sample_at = elapsed
			var enemies := get_nodes_in_group("enemies").size()
			var lvl: int = int(player.get("current_level")) if "current_level" in player else -1
			print("SIM_AFK: t=%5.0fs hp=%4d enemies=%3d lvl=%2d" % [elapsed, int(player.get("current_hp")), enemies, lvl])
		var over: bool = bool(gr.get("_is_game_over")) if "_is_game_over" in gr else false
		var win: bool = bool(gr.get("_is_victory")) if "_is_victory" in gr else false
		if over or win:
			var verdict := "VICTORY (full AFK clear — too easy)" if win else "DIED at %.0fs" % float(gd.get("run_elapsed"))
			print("SIM_AFK_RESULT: %s | difficulty=%s mode=%s" % [verdict, String(gd.get("difficulty")), _mode])
			Engine.time_scale = 1.0
			quit(0)
			return

# Dumb flee: weighted average of directions away from enemies within 320px
# (closer = heavier), fed into the same TouchInput channel the joystick uses.
func _steer_away(player: Node2D) -> void:
	var ti := root.get_node_or_null("/root/TouchInput")
	if ti == null:
		return
	var flee := Vector2.ZERO
	for e in get_nodes_in_group("enemies"):
		if not (e is Node2D):
			continue
		var diff: Vector2 = player.global_position - (e as Node2D).global_position
		var dist := diff.length()
		if dist < 1.0 or dist > 320.0:
			continue
		flee += diff / dist * (320.0 - dist) / 320.0
	if flee.length() < 0.05:
		ti.set("move_vector", Vector2.ZERO)
	else:
		ti.set("move_vector", flee.normalized())
