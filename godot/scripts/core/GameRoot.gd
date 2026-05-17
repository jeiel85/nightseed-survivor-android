extends Node2D

const XP_GEM_SCENE := preload("res://scenes/pickups/XPGem.tscn")
const GOLD_COIN_SCENE := preload("res://scenes/pickups/GoldCoin.tscn")

@onready var player: Player = $Player
@onready var hud: HUD = $HUD
@onready var enemy_spawner: EnemySpawner = $EnemySpawner
@onready var wave_manager: WaveManager = $WaveManager
@onready var level_up_ui: LevelUpUI = $LevelUpUI
@onready var story_banner: StoryBanner = $StoryBanner
@onready var background_rect: ColorRect = $Background
@onready var ground_tiler: BackgroundTiler = $GroundTiler
@onready var result_panel: CanvasLayer = $ResultPanel
@onready var result_backdrop: ColorRect = $ResultPanel/Backdrop
@onready var result_title: Label = $ResultPanel/Panel/VBox/Title
@onready var result_subtitle: Label = $ResultPanel/Panel/VBox/Subtitle
@onready var result_stats: Label = $ResultPanel/Panel/VBox/Stats
@onready var result_next_goal: Label = $ResultPanel/Panel/VBox/NextGoal
@onready var result_achievements: Label = $ResultPanel/Panel/VBox/Achievements
@onready var btn_revive: Button = $ResultPanel/Panel/VBox/BtnRevive
@onready var btn_double_gold: Button = $ResultPanel/Panel/VBox/BtnDoubleGold
@onready var btn_restart: Button = $ResultPanel/Panel/VBox/BtnRestart
@onready var btn_menu: Button = $ResultPanel/Panel/VBox/BtnMenu

var _survival_time: float = 0.0
var _total_time: float = 300.0
var _is_game_over: bool = false
var _is_victory: bool = false

var _run_damage_taken_at_lv5: bool = false
var _run_lv5_locked: bool = false
var _run_evolved: bool = false
var _run_boss_killed: bool = false
var _last_seen_hp: int = -1
var _newly_unlocked_achievements: Array = []

# Rewarded-ad gates — each is one-shot per run so the player can't
# repeatedly farm a single ad slot for free progress.
var _revive_used: bool = false
var _double_gold_used: bool = false
var _displayed_session_gold: int = 0  # what we showed on the result panel

func _ready() -> void:
	AudioManager.play_bgm("game")
	randomize()
	_apply_stage_background()
	enemy_spawner.setup(player)
	wave_manager.setup(enemy_spawner, GameData.selected_stage)
	_total_time = wave_manager.get_total_time()

	player.hp_changed.connect(hud.set_hp)
	player.hp_changed.connect(_on_hp_changed_track)
	player.xp_changed.connect(_on_player_xp_changed)
	player.leveled_up.connect(_on_player_leveled_up)
	player.gold_changed.connect(hud.set_gold)
	player.kill_count_changed.connect(hud.set_kills)
	player.died.connect(_on_player_died)

	enemy_spawner.enemy_killed.connect(_on_enemy_killed)
	level_up_ui.upgrade_chosen.connect(_on_upgrade_chosen)
	wave_manager.boss_spawned.connect(_on_boss_spawned)

	btn_restart.pressed.connect(_on_restart_pressed)
	btn_menu.pressed.connect(_on_menu_pressed)
	btn_revive.pressed.connect(_on_revive_pressed)
	btn_double_gold.pressed.connect(_on_double_gold_pressed)
	if AdManager:
		AdManager.rewarded_granted.connect(_on_rewarded_granted)
		AdManager.rewarded_failed.connect(_on_rewarded_failed)
		AdManager.rewarded_dismissed.connect(_on_rewarded_dismissed)

	result_panel.visible = false
	result_subtitle.text = ""

	hud.set_hp(player.current_hp, player.max_hp)
	hud.set_time(_total_time)
	hud.set_level(1)
	hud.set_kills(0)
	hud.set_gold(0)

	_play_stage_intro()

func _apply_stage_background() -> void:
	var stage: Dictionary = Stages.get_stage(GameData.selected_stage)
	if stage.is_empty():
		return
	var tone = stage.get("bg", null)
	if not (tone is Dictionary) or tone.is_empty():
		return
	if is_instance_valid(ground_tiler):
		ground_tiler.apply_tone(tone)
	if is_instance_valid(background_rect) and tone.has("void"):
		var arr = tone["void"]
		if arr is Array and arr.size() >= 3:
			var a: float = float(arr[3]) if arr.size() >= 4 else 1.0
			background_rect.color = Color(float(arr[0]), float(arr[1]), float(arr[2]), a)

func _play_stage_intro() -> void:
	if not is_instance_valid(story_banner):
		return
	var lines: Array = Story.get_stage_lines(GameData.selected_stage, "intro")
	if lines.is_empty():
		var hint: String = Story.get_repeat_hint()
		if hint.is_empty():
			return
		lines = [{"speaker": "", "text": hint}]
	story_banner.play_lines(lines)

func _on_boss_spawned() -> void:
	if not is_instance_valid(story_banner):
		return
	var lines: Array = [{"speaker": "", "text": Localization.tr_key("boss_warning")}]
	lines.append_array(Story.get_stage_lines(GameData.selected_stage, "boss_intro"))
	story_banner.play_lines(lines)

func _process(delta: float) -> void:
	if _is_game_over or _is_victory:
		return
	_survival_time += delta
	GameData.run_elapsed = _survival_time
	wave_manager.update(delta)
	hud.set_time(_total_time - _survival_time)
	if _survival_time >= _total_time:
		_on_victory()

func _on_player_xp_changed(current: int, needed: int) -> void:
	hud.set_xp(current, needed)

func _on_player_leveled_up(level: int) -> void:
	hud.set_level(level)
	level_up_ui.show_for_player(player)
	AudioManager.play("level_up", -4.0)
	if level == 5 and not _run_damage_taken_at_lv5:
		_run_lv5_locked = true
		_try_unlock("untouchable")
	elif level == 5:
		_run_lv5_locked = true
	if level == 10 and _survival_time < 126.0:
		_try_unlock("speed_runner")
	if level >= 20:
		_try_unlock("completionist")

func _on_hp_changed_track(current: int, _max_val: int) -> void:
	if _last_seen_hp >= 0 and current < _last_seen_hp and not _run_lv5_locked:
		_run_damage_taken_at_lv5 = true
	_last_seen_hp = current

func _try_unlock(key: String) -> void:
	if GameData.try_unlock_achievement(key):
		_newly_unlocked_achievements.append(key)

func _on_enemy_killed(xp: int, gold: int, pos: Vector2) -> void:
	player.add_kill()
	if xp >= 100:
		_run_boss_killed = true
		_try_unlock("boss_slayer")
	var gem := XP_GEM_SCENE.instantiate() as XPGem
	gem.xp_value = xp
	gem.global_position = pos
	add_child(gem)
	if gold > 0:
		var coin := GOLD_COIN_SCENE.instantiate() as GoldCoin
		coin.gold_value = gold
		coin.global_position = pos + Vector2(randf_range(-12.0, 12.0), randf_range(-12.0, 12.0))
		add_child(coin)

func _on_player_died() -> void:
	_is_game_over = true
	await get_tree().create_timer(0.5).timeout
	_show_result(false)

func _on_victory() -> void:
	_is_victory = true
	_show_result(true)

func _show_result(victory: bool) -> void:
	get_tree().paused = true
	if victory:
		_try_unlock("first_survivor")
		if GameData.difficulty != "normal":
			_try_unlock("hard_mode_clear")
	if player.kill_count >= 200:
		_try_unlock("killer_instinct")
	if player.session_gold >= 500:
		_try_unlock("wealthy")
	if player.weapon_manager.weapons.size() >= 4:
		_try_unlock("combo_master")
	# Gold + leaderboard submission are deferred to the Restart/Menu press,
	# so the rewarded-ad "Double Gold" CTA can still re-render the result
	# panel before we commit any meta-progress. See _commit_run_results().
	result_panel.visible = true
	_refresh_ad_buttons(victory)
	if is_instance_valid(result_backdrop):
		result_backdrop.color = Color(0.22, 0.12, 0.04, 0.82) if victory else Color(0.18, 0.04, 0.04, 0.84)
	if victory:
		result_title.text = Localization.tr_key("result_victory")
		result_title.modulate = Color(0.95, 0.9, 0.2)
		result_subtitle.text = Localization.tr_key("result_fragment_recovered")
		result_subtitle.modulate = Color(1, 1, 1, 1)
		AudioManager.play("victory", 0.0)
		var clear_lines: Array = Story.get_stage_lines(GameData.selected_stage, "clear")
		if is_instance_valid(story_banner) and not clear_lines.is_empty():
			story_banner.play_lines(clear_lines)
	else:
		result_title.text = Localization.tr_key("result_gameover")
		result_title.modulate = Color(1.0, 0.3, 0.3)
		result_subtitle.text = ""
		AudioManager.play("defeat", 0.0)
	_play_title_pop()
	var tm := int(_survival_time)
	var base_lines: Array = [
		Localization.tr_key("result_survived_fmt") % [tm / 60, tm % 60],
		Localization.tr_key("result_kills_fmt") % player.kill_count,
		Localization.tr_key("result_gold_fmt") % 0,
	]
	result_stats.text = "\n".join(base_lines)
	_start_gold_count_up(player.session_gold, tm)
	result_next_goal.text = _result_next_goal_text()
	result_achievements.text = _format_new_achievements()
	result_achievements.visible = result_achievements.text != ""
	btn_restart.text = Localization.tr_key("btn_play_again") if victory else Localization.tr_key("btn_retry")
	btn_menu.text = Localization.tr_key("btn_main_menu")
	ButtonStyles.apply(btn_restart, ButtonStyles.VICTORY if victory else ButtonStyles.DEFEAT)
	ButtonStyles.apply(btn_menu, ButtonStyles.NEUTRAL)
	ButtonStyles.apply(btn_revive, ButtonStyles.REWARD_AD)
	ButtonStyles.apply(btn_double_gold, ButtonStyles.REWARD_AD)

# Quick scale-pop on the result title so victory/defeat reads as an event, not
# a static label. Runs even while the tree is paused.
func _play_title_pop() -> void:
	if not is_instance_valid(result_title):
		return
	result_title.pivot_offset = result_title.size * 0.5
	result_title.scale = Vector2(0.7, 0.7)
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(result_title, "scale", Vector2(1.06, 1.06), 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(result_title, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

# Count up "Gold earned" from 0 → session_gold over ~0.9s so the reward feels
# earned. The other two stat lines stay static while the third re-renders.
func _start_gold_count_up(target: int, time_seconds: int) -> void:
	if target <= 0:
		_render_stats_with_gold(0, time_seconds)
		return
	var duration: float = 0.9 if target < 300 else 1.2
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_method(
		func(val: float) -> void: _render_stats_with_gold(int(val), time_seconds),
		0.0, float(target), duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_callback(func() -> void: _render_stats_with_gold(target, time_seconds))

func _render_stats_with_gold(g: int, time_seconds: int) -> void:
	var lines: Array = [
		Localization.tr_key("result_survived_fmt") % [time_seconds / 60, time_seconds % 60],
		Localization.tr_key("result_kills_fmt") % player.kill_count,
		Localization.tr_key("result_gold_fmt") % g,
	]
	result_stats.text = "\n".join(lines)

# How much more gold is needed for the cheapest unmaxed permanent upgrade.
# Result-panel call site shows a *projected* total (current bank + this
# session, doubled if the Double Gold rewarded-ad was watched) so the line
# stays accurate even though we haven't banked the session yet.
func _result_next_goal_text() -> String:
	var session_multiplier: int = 2 if _double_gold_used else 1
	var expected_total: int = GameData.gold + player.session_gold * session_multiplier
	var cheapest: int = -1
	for key in GameData.permanent_upgrades.keys():
		var cost: int = GameData.get_upgrade_cost(key)
		if cost <= 0:
			continue
		if cheapest < 0 or cost < cheapest:
			cheapest = cost
	if cheapest < 0:
		return Localization.tr_key("menu_next_goal_maxed")
	if expected_total >= cheapest:
		return Localization.tr_key("result_next_goal_ready")
	return Localization.tr_key("result_next_goal_fmt") % (cheapest - expected_total)

func _result_next_goal_text_with_extra(_ignored: int) -> String:
	return _result_next_goal_text()

func _format_new_achievements() -> String:
	if _newly_unlocked_achievements.is_empty():
		return ""
	var parts: Array = [Localization.tr_key("result_new_ach")]
	for key in _newly_unlocked_achievements:
		var ach_name: String = Achievements.display_name(key)
		var ach_gold: int = int(Achievements.DATA[key]["gold"])
		parts.append(Localization.tr_key("result_ach_line") % [ach_name, ach_gold])
	return "  ·  ".join(parts)

func _on_restart_pressed() -> void:
	_commit_run_results()
	get_tree().paused = false
	Transition.change_scene("res://scenes/main/GameRoot.tscn")

func _on_menu_pressed() -> void:
	_commit_run_results()
	get_tree().paused = false
	Transition.change_scene("res://scenes/ui/MainMenu.tscn")

# Banks the session into meta progress and submits to leaderboards. Called
# from the Restart/Menu press so the rewarded-ad Double Gold CTA can mutate
# the banked value before commit, and so a revive doesn't double-bank.
func _commit_run_results() -> void:
	var banked: int = player.session_gold
	if _double_gold_used:
		banked = banked * 2
	GameData.add_gold(banked)
	# Submit using the raw run stats (kills/gold/time/difficulty). Score
	# formula lives in LeaderboardManager and is the same per submission;
	# Play's "best score" mode means re-submission is safe if the user
	# revived earlier.
	LeaderboardManager.submit_run(
		GameData.selected_stage,
		player.kill_count,
		player.session_gold,
		int(_survival_time),
		GameData.difficulty,
	)

func _refresh_ad_buttons(victory: bool) -> void:
	# Revive only makes sense on defeat and only the first time per run.
	# Double Gold is offered on both outcomes (capped to one use).
	var revive_visible: bool = (not victory) and (not _revive_used) and AdManager.is_rewarded_ready()
	var double_visible: bool = (not _double_gold_used) and player.session_gold > 0 and AdManager.is_rewarded_ready()
	btn_revive.visible = revive_visible
	btn_double_gold.visible = double_visible
	btn_revive.text = Localization.tr_key("btn_revive_ad")
	btn_double_gold.text = Localization.tr_key("btn_double_gold_ad")

func _on_revive_pressed() -> void:
	if _revive_used:
		return
	btn_revive.disabled = true
	AdManager.show_rewarded(AdManager.REWARD_TAG_REVIVE)

func _on_double_gold_pressed() -> void:
	if _double_gold_used:
		return
	btn_double_gold.disabled = true
	AdManager.show_rewarded(AdManager.REWARD_TAG_DOUBLE_GOLD)

func _on_rewarded_granted(tag: String) -> void:
	if tag == AdManager.REWARD_TAG_REVIVE:
		_do_revive()
	elif tag == AdManager.REWARD_TAG_DOUBLE_GOLD:
		_double_gold_used = true
		btn_double_gold.visible = false
		# Re-render the gold count-up with the doubled amount.
		_start_gold_count_up(player.session_gold * 2, int(_survival_time))
		result_next_goal.text = _result_next_goal_text_with_extra(player.session_gold)

func _on_rewarded_failed(_tag: String, _reason: String) -> void:
	btn_revive.disabled = false
	btn_double_gold.disabled = false

func _on_rewarded_dismissed(_tag: String) -> void:
	btn_revive.disabled = false
	btn_double_gold.disabled = false

func _do_revive() -> void:
	_revive_used = true
	_is_game_over = false
	result_panel.visible = false
	get_tree().paused = false
	player.revive(0.5, 3.0)
	# Clear nearby threats so revive doesn't immediately re-kill the player
	# from the same pack that just downed them.
	var clear_radius_sq: float = 280.0 * 280.0
	for e in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(e):
			continue
		if e.global_position.distance_squared_to(player.global_position) <= clear_radius_sq:
			if e.has_method("queue_free"):
				e.queue_free()
	# Outward "revived" ring on the player.
	var burst := DeathBurst.new()
	burst.global_position = player.global_position
	burst.burst_color = Color(0.95, 0.95, 0.4, 1.0)
	burst.particle_count = 18
	burst.spread = 160.0
	burst.lifetime = 0.55
	add_child(burst)
	_last_seen_hp = player.current_hp

func _on_upgrade_chosen(upgrade_id: String) -> void:
	if upgrade_id.begins_with("new:"):
		_add_weapon(upgrade_id.substr(4))
	elif upgrade_id.begins_with("up:"):
		player.weapon_manager.upgrade_weapon(upgrade_id.substr(3))
	elif upgrade_id.begins_with("passive:"):
		player.weapon_manager.apply_passive(upgrade_id.substr(8))
	elif upgrade_id.begins_with("evolve:"):
		player.weapon_manager.evolve_weapon(upgrade_id.substr(7))
		_run_evolved = true
		_try_unlock("evolver")
		AudioManager.play("evolve", 0.0)

func _add_weapon(wname: String) -> void:
	# Guard: if the player somehow gets offered a "new:" card for a weapon
	# they already own (e.g. levelup pool generated while a starting weapon's
	# _ready hadn't yet set weapon_name), fall through to an upgrade instead of
	# inserting a duplicate WeaponBase into wm.weapons.
	if player.weapon_manager.has_weapon(wname):
		player.weapon_manager.upgrade_weapon(wname)
		return
	var w: WeaponBase = null
	match wname:
		"Spirit Orb":  w = SpiritOrb.new()
		"Fire Wisp":   w = FireWisp.new()
		"Thorn Ring":  w = ThornRing.new()
		"Star Needle": w = StarNeedle.new()
	if w:
		player.weapon_manager.add_weapon(w)
