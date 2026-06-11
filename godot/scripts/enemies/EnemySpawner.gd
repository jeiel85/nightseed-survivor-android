extends Node2D
class_name EnemySpawner

signal enemy_killed(xp: int, gold: int, pos: Vector2)

@export var max_enemies: int = 280
@export var spawn_radius: float = 750.0

# 2026-06 난이도 리워크: 한 방향으로 도주하면 무리가 꼬리에 끌려오기만 하고
# (적 수 상한 도달 → 신규 스폰 중단) 위협이 사라지는 circle-kiting 자동사냥
# 루트가 있었다. 플레이어에게서 RECYCLE_DISTANCE 이상 떨어진 적을 진행 방향
# 앞쪽 스폰 링으로 재배치해 차단한다 (recycle_exempt = 보스/미니보스 제외).
const RECYCLE_DISTANCE: float = 1050.0
const RECYCLE_CHECK_INTERVAL: float = 1.0

var player: Node2D
var _enemy_pool: Array = []
var _spawn_count: int = 2
var _enemy_tint: Color = Color(1, 1, 1, 1)
var _apply_tint: bool = false
var _recycle_accum: float = 0.0

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

func _process(delta: float) -> void:
	if not is_instance_valid(player):
		return
	_recycle_accum += delta
	if _recycle_accum < RECYCLE_CHECK_INTERVAL:
		return
	_recycle_accum = 0.0
	var heading := Vector2.ZERO
	if player is CharacterBody2D:
		heading = (player as CharacterBody2D).velocity
	for e in get_tree().get_nodes_in_group("enemies"):
		if not (e is Node2D):
			continue
		if e.get("recycle_exempt") == true:
			continue
		var n2 := e as Node2D
		if n2.global_position.distance_to(player.global_position) < RECYCLE_DISTANCE:
			continue
		# 도주 중이면 진행 방향 ±60° 부채꼴 앞에, 정지 상태면 임의 방향에 재배치.
		var angle: float
		if heading.length() > 10.0:
			angle = heading.angle() + randf_range(-PI / 3.0, PI / 3.0)
		else:
			angle = randf_range(0.0, TAU)
		n2.global_position = player.global_position + Vector2.RIGHT.rotated(angle) * spawn_radius

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
