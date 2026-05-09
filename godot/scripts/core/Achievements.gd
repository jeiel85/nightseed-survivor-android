class_name Achievements
extends RefCounted

const DATA: Dictionary = {
	"first_survivor": {
		"name": "First Survivor",
		"desc": "Survive the full 10 minutes",
		"gold": 200,
	},
	"speed_runner": {
		"name": "Speed Runner",
		"desc": "Reach Level 10 in under 3 minutes",
		"gold": 150,
	},
	"killer_instinct": {
		"name": "Killer Instinct",
		"desc": "Kill 200 enemies in one run",
		"gold": 100,
	},
	"untouchable": {
		"name": "Untouchable",
		"desc": "Reach Level 5 without taking damage",
		"gold": 200,
	},
	"evolver": {
		"name": "Evolver",
		"desc": "Evolve a weapon",
		"gold": 250,
	},
	"boss_slayer": {
		"name": "Boss Slayer",
		"desc": "Defeat the final boss",
		"gold": 300,
	},
}

const ORDER: Array = [
	"first_survivor", "speed_runner", "killer_instinct",
	"untouchable", "evolver", "boss_slayer",
]
