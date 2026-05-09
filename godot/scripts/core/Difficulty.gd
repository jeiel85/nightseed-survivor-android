class_name Difficulty
extends RefCounted

const DATA: Dictionary = {
	"normal": {
		"name": "Normal",
		"hp_mult": 1.0,
		"dmg_mult": 1.0,
		"reward_mult": 1.0,
		"color": Color(0.6, 0.85, 0.6),
	},
	"hard": {
		"name": "Hard",
		"hp_mult": 1.5,
		"dmg_mult": 1.3,
		"reward_mult": 1.3,
		"color": Color(1.0, 0.7, 0.3),
	},
	"nightmare": {
		"name": "Nightmare",
		"hp_mult": 2.5,
		"dmg_mult": 1.7,
		"reward_mult": 1.7,
		"color": Color(1.0, 0.3, 0.4),
	},
}

const ORDER: Array = ["normal", "hard", "nightmare"]

static func get_data(key: String) -> Dictionary:
	return DATA.get(key, DATA["normal"])

static func next_key(key: String) -> String:
	var idx: int = ORDER.find(key)
	if idx == -1:
		return ORDER[0]
	return ORDER[(idx + 1) % ORDER.size()]
