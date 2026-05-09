class_name Evolutions
extends RefCounted

const RULES: Dictionary = {
	"Moon Dagger": {
		"evolved_name": "Crescent Storm",
		"required_passive": "battle_focus",
		"passive_level": 3,
		"weapon_level": 5,
		"desc": "3-dagger fan + bonus damage",
		"color": Color(0.5, 0.85, 1.0),
	},
	"Spirit Orb": {
		"evolved_name": "Eternal Halo",
		"required_passive": "magnet_charm",
		"passive_level": 3,
		"weapon_level": 5,
		"desc": "Twin halo of orbs, bigger orbit",
		"color": Color(0.4, 0.95, 0.95),
	},
}

static func can_evolve(weapon_name: String, weapon_level: int, passive_level_fn: Callable) -> bool:
	if not RULES.has(weapon_name):
		return false
	var rule: Dictionary = RULES[weapon_name]
	if weapon_level < int(rule["weapon_level"]):
		return false
	var pl: int = int(passive_level_fn.call(String(rule["required_passive"])))
	return pl >= int(rule["passive_level"])
