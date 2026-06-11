class_name Difficulty
extends RefCounted

const DATA: Dictionary = {
	# 2026-06 난이도 리워크: Normal이 적을 기본보다 약화(0.85/0.9)시키던
	# "훈련용 보정"을 제거하고 기준선(1.0)으로 올림. 상위 난이도도 한 단계씩
	# 상향 — 영구강화(철의 심장 +100HP, 파워코어 +50%)가 받쳐주는 전제.
	"normal": {
		"name": "Normal",
		"name_key": "difficulty_normal",
		"hp_mult": 1.0,
		"dmg_mult": 1.0,
		"reward_mult": 1.0,
		"color": Color(0.6, 0.85, 0.6),
	},
	"hard": {
		"name": "Hard",
		"name_key": "difficulty_hard",
		"hp_mult": 1.7,
		"dmg_mult": 1.45,
		"reward_mult": 1.3,
		"color": Color(1.0, 0.7, 0.3),
	},
	"nightmare": {
		"name": "Nightmare",
		"name_key": "difficulty_nightmare",
		"hp_mult": 2.9,
		"dmg_mult": 2.0,
		"reward_mult": 1.7,
		"color": Color(1.0, 0.3, 0.4),
	},
}

const ORDER: Array = ["normal", "hard", "nightmare"]

static func get_data(key: String) -> Dictionary:
	return DATA.get(key, DATA["normal"])

static func display_name(key: String) -> String:
	var d := get_data(key)
	if d.has("name_key") and Localization:
		return Localization.tr_key(String(d["name_key"]), String(d.get("name", "?")))
	return String(d.get("name", "?"))

static func next_key(key: String) -> String:
	var idx: int = ORDER.find(key)
	if idx == -1:
		return ORDER[0]
	return ORDER[(idx + 1) % ORDER.size()]
