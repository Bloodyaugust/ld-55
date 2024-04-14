extends Node

const battlefield_scene: PackedScene = preload("res://scenes/battlefield.tscn")
const demon_scene: PackedScene = preload("res://actors/demon.tscn")
const wave_duration: float = 10.0

var _current_game_scene: Variant = null
var _summoning_queue: Array = []
var _summoning_cooldown: float = 0.0

func queue_demon(summoning_area: Node2D, demon: DemonData) -> void:
	_summoning_queue.append({ "summoning_area": summoning_area, "demon": demon})
	Store.state[GameConstants.STORE_KEYS.RESOURCES][summoning_area.team]["total"] = Store.state[GameConstants.STORE_KEYS.RESOURCES][summoning_area.team]["total"] - demon.cost
	Store.set_state(GameConstants.STORE_KEYS.RESOURCES, Store.state[GameConstants.STORE_KEYS.RESOURCES])
	Store.set_state(GameConstants.STORE_KEYS.SUMMONING_QUEUE, _summoning_queue)
	
func _summon_queued_demons() -> void:
	for summon in _summoning_queue:
		summon_demon(summon["summoning_area"], summon["demon"])
	
	_summoning_queue = []
	_summoning_cooldown = wave_duration
	Store.set_state(GameConstants.STORE_KEYS.SUMMONING_QUEUE, _summoning_queue)

func summon_demon(summoning_area: Node2D, demon: DemonData) -> void:
	var _new_demon: Demon = demon_scene.instantiate() as Demon
	
	_new_demon.data = demon
	_new_demon.team = summoning_area.team
	_new_demon.global_position = summoning_area.global_position

	_current_game_scene.add_child(_new_demon)
	_new_demon.set_nav_target(summoning_area.nav_target)

func waypoint_captured() -> void:
	var _waypoints := get_tree().get_nodes_in_group(GameConstants.WAYPOINTS_GROUP)
	var _resource_rates = _waypoints.reduce(func (accu, waypoint: Waypoint):
		if waypoint._team != GameConstants.TEAM.NEUTRAL:
			accu[waypoint._team] = accu[waypoint._team] + waypoint.resource_rate
		return accu
		, { GameConstants.TEAM.AI: GameConstants.RESOURCES_STARTING_RATE, GameConstants.TEAM.PLAYER: GameConstants.RESOURCES_STARTING_RATE })

	Store.state[GameConstants.STORE_KEYS.RESOURCES][GameConstants.TEAM.AI]["rate"] = _resource_rates[GameConstants.TEAM.AI]
	Store.state[GameConstants.STORE_KEYS.RESOURCES][GameConstants.TEAM.PLAYER]["rate"] = _resource_rates[GameConstants.TEAM.PLAYER]
	Store.set_state(GameConstants.STORE_KEYS.RESOURCES, Store.state[GameConstants.STORE_KEYS.RESOURCES])


func tower_destroyed(team: GameConstants.TEAM) -> void:
	_current_game_scene.queue_free()
	
	match team:
		GameConstants.TEAM.AI:
			Store.set_state("winner", GameConstants.TEAM.PLAYER)
		GameConstants.TEAM.PLAYER:
			Store.set_state("winner", GameConstants.TEAM.AI)
	
	Store.set_state("game", GameConstants.GAME_OVER)
	ViewController.set_client_view(ViewController.CLIENT_VIEWS.SCORE)
	
func _update_resource_totals(delta) -> void:
	Store.state[GameConstants.STORE_KEYS.RESOURCES][GameConstants.TEAM.AI]["total"] = Store.state[GameConstants.STORE_KEYS.RESOURCES][GameConstants.TEAM.AI]["total"] + Store.state[GameConstants.STORE_KEYS.RESOURCES][GameConstants.TEAM.AI]["rate"] * delta
	Store.state[GameConstants.STORE_KEYS.RESOURCES][GameConstants.TEAM.PLAYER]["total"] = Store.state[GameConstants.STORE_KEYS.RESOURCES][GameConstants.TEAM.PLAYER]["total"] + Store.state[GameConstants.STORE_KEYS.RESOURCES][GameConstants.TEAM.PLAYER]["rate"] * delta
	Store.set_state(GameConstants.STORE_KEYS.RESOURCES, Store.state[GameConstants.STORE_KEYS.RESOURCES])

func _update_summoning_cooldown(delta) -> void:
	_summoning_cooldown = clamp(_summoning_cooldown - delta, 0.0, wave_duration)
	Store.set_state(GameConstants.STORE_KEYS.TIME_TO_SUMMONING, _summoning_cooldown)
 
func _on_store_state_changed(state_key: String, substate: Variant) -> void:
	match state_key:
		"game":
			match substate:
				GameConstants.GAME_STARTING:
					_current_game_scene = battlefield_scene.instantiate()
					_summoning_cooldown = wave_duration
					
					get_tree().get_root().add_child(_current_game_scene)
					
					Store.set_state(GameConstants.STORE_KEYS.RESOURCES, {
						GameConstants.TEAM.AI: {
							"total": GameConstants.RESOURCES_STARTING_TOTAL,
							"rate": GameConstants.RESOURCES_STARTING_RATE	
						},
						GameConstants.TEAM.PLAYER: {
							"total": GameConstants.RESOURCES_STARTING_TOTAL,
							"rate": GameConstants.RESOURCES_STARTING_RATE
						}
					})
					Store.set_state("game", GameConstants.GAME_IN_PROGRESS)
					_summoning_queue = []
					Store.set_state(GameConstants.STORE_KEYS.SUMMONING_QUEUE, [])


func _ready():
	Store.state_changed.connect(_on_store_state_changed)
	Store.set_state(GameConstants.STORE_KEYS.SUMMONING_QUEUE, [])


func _unhandled_input(event) -> void:
	if event.is_action_released("clear_selection"):
		Store.set_state(GameConstants.STORE_KEYS.SELECTED_SUMMONING_AREA, null)
		
func _process(delta) -> void:
	if Store.state.game == GameConstants.GAME_IN_PROGRESS:
		_update_resource_totals(delta)
		_update_summoning_cooldown(delta)
		if is_equal_approx(_summoning_cooldown, 0.0):
			_summon_queued_demons()
	
	
