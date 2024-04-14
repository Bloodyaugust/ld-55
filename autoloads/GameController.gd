extends Node

const battlefield_scene: PackedScene = preload("res://scenes/battlefield.tscn")
const demon_scene: PackedScene = preload("res://actors/demon.tscn")

var _current_game_scene: Variant = null


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


func _on_store_state_changed(state_key: String, substate: Variant) -> void:
	match state_key:
		"game":
			match substate:
				GameConstants.GAME_STARTING:
					_current_game_scene = battlefield_scene.instantiate()
					
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


func _ready():
	Store.state_changed.connect(_on_store_state_changed)


func _unhandled_input(event) -> void:
	if event.is_action_released("clear_selection"):
		Store.set_state(GameConstants.STORE_KEYS.SELECTED_SUMMONING_AREA, null)
		
func _process(delta) -> void:
	if Store.state.game == GameConstants.GAME_IN_PROGRESS:
		_update_resource_totals(delta)
	
	
