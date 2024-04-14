extends Node

const GAME_IN_PROGRESS = "GAME_IN_PROGRESS"
const GAME_OVER = "GAME_OVER"
const GAME_STARTING = "GAME_STARTING"

enum TEAM {
	AI,
	PLAYER,
	NEUTRAL
}

enum DAMAGE_TYPE {
	BLUNT,
	PIERCING,
	MAGIC
}
const DAMAGE_TYPE_NAMES = {
	DAMAGE_TYPE.BLUNT: "Blunt",
	DAMAGE_TYPE.PIERCING: "Piercing",
	DAMAGE_TYPE.MAGIC: "Magic",
}

enum ARMOR_TYPE {
	LIGHT,
	MEDIUM,
	HEAVY
}
const ARMOR_TYPE_NAMES = {
	ARMOR_TYPE.LIGHT: "Light",
	ARMOR_TYPE.MEDIUM: "Medium",
	ARMOR_TYPE.HEAVY: "Heavy",
}

const RESOURCES_STARTING_TOTAL = 0.0
const RESOURCES_STARTING_RATE = 5.0
const AI_COST_HANDICAP = 4.0

const WAYPOINTS_GROUP = "Waypoints"
const SUMMONING_AREAS_GROUP = "SummoningArea"
const DAMAGEABLE_GROUP = "Damageable"
const DEMONS_GROUP = "Demon"

const STORE_KEYS := {
	"SELECTED_SUMMONING_AREA": "selected_summoning_area",
	"RESOURCES": "resources",
	"SELECTION": "selection"
}

const DEMON_DATA := {
	"melee": preload ("res://data/demons/melee.tres"),
	"ranged": preload ("res://data/demons/ranged.tres"),
	"flying": preload ("res://data/demons/flying.tres")	
}
