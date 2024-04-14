extends Node

@onready var _summoning_areas: Array[Node] = get_tree().get_nodes_in_group(GameConstants.SUMMONING_AREAS_GROUP).filter(func(summoning_area): return summoning_area.team == GameConstants.TEAM.AI)

var _next_demon: DemonData


func _process(delta):
	if Store.state[GameConstants.STORE_KEYS.RESOURCES][GameConstants.TEAM.AI]["total"] > _next_demon.cost * GameConstants.AI_COST_HANDICAP:
		GameController.queue_demon(_summoning_areas.pick_random(), _next_demon)
		_next_demon = GameConstants.DEMON_DATA.values().pick_random()
	
	
func _ready():
	_next_demon = GameConstants.DEMON_DATA.values().pick_random()
	
