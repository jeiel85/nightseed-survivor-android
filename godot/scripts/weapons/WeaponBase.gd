extends Node2D
class_name WeaponBase

# Emitted right after fire() runs each cooldown tick. EmberRenewal (Pyromancer)
# listens via WeaponManager.weapon_fired to count fires for its heal cadence.
signal fired

@export var weapon_name: String = "Weapon"
@export var base_damage: int = 10
@export var base_cooldown: float = 1.0

var player: Node2D
var level: int = 1
var damage_multiplier: float = 1.0
var cooldown_multiplier: float = 1.0
var evolved: bool = false
var _cooldown_timer: float = 0.0

func _process(delta: float) -> void:
	if not is_instance_valid(player):
		return
	_cooldown_timer -= delta
	if _cooldown_timer <= 0.0:
		_cooldown_timer = maxf(base_cooldown * cooldown_multiplier, 0.15)
		fire()
		fired.emit()

func fire() -> void:
	pass

func get_damage() -> int:
	return int(base_damage * damage_multiplier)

# Cooldown shown in the level-up UI. Default: the actual fire interval used by
# WeaponBase._process. Subclasses whose damage cadence is not driven by
# base_cooldown (e.g. SpiritOrb's orbiting ticks) must override so the UI
# doesn't surface a sentinel value like 9999.
func get_display_cooldown() -> float:
	return maxf(base_cooldown * cooldown_multiplier, 0.15)

# Cooldown the weapon will have after upgrade(). Mirrors the * 0.90 in upgrade().
# Subclasses that change cadence differently on upgrade should override too.
func get_display_next_cooldown() -> float:
	return maxf(maxf(base_cooldown * UPGRADE_COOLDOWN_MULT, 0.2) * cooldown_multiplier, 0.15)

# 2026-06 난이도 리워크: 레벨당 ×1.25/×0.88 복리는 5분 안에 적 시간 스케일을
# 압도해 "자동사냥"이 가능했다. ×1.22/×0.90으로 스노볼을 다듬는다 (Lv5 기준
# DPS 약 -15%). docs/BALANCE.md §9 참고.
const UPGRADE_DAMAGE_MULT := 1.22
const UPGRADE_COOLDOWN_MULT := 0.90

func upgrade() -> void:
	level += 1
	base_damage = int(base_damage * UPGRADE_DAMAGE_MULT)
	base_cooldown = maxf(base_cooldown * UPGRADE_COOLDOWN_MULT, 0.2)

func evolve() -> void:
	evolved = true
	base_damage = int(base_damage * 1.4)
	base_cooldown = maxf(base_cooldown * 0.85, 0.15)

func find_nearest_enemy() -> Node2D:
	var enemies := get_tree().get_nodes_in_group("enemies")
	var nearest: Node2D = null
	var nearest_dist: float = INF
	for e in enemies:
		if not is_instance_valid(e):
			continue
		var d: float = player.global_position.distance_to(e.global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest = e
	return nearest
