extends Node

@onready var _ai_summoning_areas: Array[Node] = (
	get_tree()
	. get_nodes_in_group(GameConstants.SUMMONING_AREAS_GROUP)
	. filter(func(summoning_area): return summoning_area.team == GameConstants.TEAM.AI)
)
@onready var _player_summoning_areas: Array[Node] = (
	get_tree()
	. get_nodes_in_group(GameConstants.SUMMONING_AREAS_GROUP)
	. filter(func(summoning_area): return summoning_area.team == GameConstants.TEAM.PLAYER)
)

var _ai_next_demon: DemonData
var _player_next_demon: DemonData


func _process(delta):
	if (
		Store.state[GameConstants.STORE_KEYS.RESOURCES][GameConstants.TEAM.AI]["total"]
		> _ai_next_demon.cost * GameConstants.AI_COST_HANDICAP
	):
		GameController.queue_demon(_ai_summoning_areas.pick_random(), _ai_next_demon)
		_ai_next_demon = GameConstants.DEMON_DATA.values().pick_random()

	if GameConstants.AI_CONTROLLED_PLAYER == true:
		if (
			Store.state[GameConstants.STORE_KEYS.RESOURCES][GameConstants.TEAM.PLAYER]["total"]
			> _player_next_demon.cost * GameConstants.AI_COST_HANDICAP
		):
			GameController.queue_demon(_player_summoning_areas.pick_random(), _player_next_demon)
			_player_next_demon = GameConstants.DEMON_DATA.values().pick_random()


func _ready():
	_ai_next_demon = GameConstants.DEMON_DATA.values().pick_random()
	_player_next_demon = GameConstants.DEMON_DATA.values().pick_random()
