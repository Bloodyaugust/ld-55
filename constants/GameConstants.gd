extends Node

const GAME_IN_PROGRESS = "GAME_IN_PROGRESS"
const GAME_OVER = "GAME_OVER"
const GAME_STARTING = "GAME_STARTING"

enum TEAM {
	AI,
	PLAYER,
	NEUTRAL
}

const RESOURCES_STARTING_TOTAL = 0.0
const RESOURCES_STARTING_RATE = 5.0

const WAYPOINTS_GROUP = "Waypoints"
const DAMAGEABLE_GROUP = "Damageable"
const DEMONS_GROUP = "Demon"

const STORE_KEYS := {
	"SELECTED_SUMMONING_AREA": "selected_summoning_area",
	"RESOURCES": "resources"
}

const DEMON_DATA := {
	"melee": preload ("res://data/demons/melee.tres"),
	"ranged": preload ("res://data/demons/ranged.tres")
}
