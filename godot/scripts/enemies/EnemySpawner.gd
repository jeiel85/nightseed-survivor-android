extends Node2D
class_name EnemySpawner

signal enemy_killed(xp: int, gold: int, pos: Vector2)

@export var max_enemies: int = 280
@export var spawn_radius: float = 750.0

var player: Node2D
var _enemy_pool: Array = []
var _spawn_count: int = 2
var _enemy_tint: Color = Color(1, 1, 1, 1)
var _apply_tint: bool = false

@onready var _timer: Timer = $SpawnTimer

func _ready() -> void:
	add_to_group("enemy_spawner")
	_timer.timeout.connect(_on_timer_timeout)
	_timer.wait_time = 1.5
	_timer.start()

func setup(p: Node2D) -> void:
	player = p
	_cache_stage_tint()

func _cache_stage_tint() -> void:
	var stage: Dictionary = Stages.get_stage(GameData.selected_stage)
	var tint_arr = stage.get("enemy_tint", null)
	if tint_arr is Array and tint_arr.size() >= 3:
		var a: float = float(tint_arr[3]) if tint_arr.size() >= 4 else 1.0
		_enemy_tint = Color(float(tint_arr[0]), float(tint_arr[1]), float(tint_arr[2]), a)
		# Forest 처럼 [1,1,1,1] 인 스테이지는 modulate 호출 자체를 스킵해서 분기 최소화.
		_apply_tint = not _enemy_tint.is_equal_approx(Color(1, 1, 1, 1))
	else:
		_enemy_tint = Color(1, 1, 1, 1)
		_apply_tint = false

func set_wave(pool: Array, interval: float, count: int) -> void:
	_enemy_pool = pool
	_spawn_count = count
	if abs(_timer.wait_time - interval) > 0.05:
		_timer.stop()
		_timer.wait_time = interval
		_timer.start()

func spawn_specific(scene: PackedScene) -> void:
	if scene == null or not is_instance_valid(player):
		return
	_do_spawn(scene)

func _on_timer_timeout() -> void:
	if _enemy_pool.is_empty() or not is_instance_valid(player):
		return
	var current := get_tree().get_nodes_in_group("enemies").size()
	if current >= max_enemies:
		return
	var available := max_enemies - current
	var count := mini(_spawn_count, available)
	for _i in range(count):
		var scene: PackedScene = _enemy_pool[randi() % _enemy_pool.size()]
		_do_spawn(scene)

func _do_spawn(scene: PackedScene) -> void:
	var enemy := scene.instantiate()
	var angle := randf_range(0.0, TAU)
	enemy.global_position = player.global_position + Vector2.RIGHT.rotated(angle) * spawn_radius
	if enemy.has_method("set_target"):
		enemy.set_target(player)
	register_enemy(enemy)
	get_parent().add_child(enemy)

# Used by Splitter (and any other in-world spawner) to make sure offspring
# kills also count toward enemy_killed → XP/gold/leaderboards.
# Also applies the stage enemy_tint so splitterlings inherit the hue.
func register_enemy(enemy: Node) -> void:
	if enemy == null:
		return
	if _apply_tint and enemy is CanvasItem:
		enemy.modulate = _enemy_tint
	if enemy.has_signal("died"):
		enemy.died.connect(func(xp: int, gold: int, pos: Vector2):
			enemy_killed.emit(xp, gold, pos)
		)
