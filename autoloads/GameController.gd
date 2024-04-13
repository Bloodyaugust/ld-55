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


func tower_destroyed(team: GameConstants.TEAM) -> void:
	_current_game_scene.queue_free()
	
	match team:
		GameConstants.TEAM.AI:
			Store.set_state("winner", GameConstants.TEAM.PLAYER)
		GameConstants.TEAM.PLAYER:
			Store.set_state("winner", GameConstants.TEAM.AI)
	
	Store.set_state("game", GameConstants.GAME_OVER)
	ViewController.set_client_view(ViewController.CLIENT_VIEWS.SCORE)


func _on_store_state_changed(state_key: String, substate: Variant) -> void:
	match state_key:
		"game":
			match substate:
				GameConstants.GAME_STARTING:
					_current_game_scene = battlefield_scene.instantiate()
					
					get_tree().get_root().add_child(_current_game_scene)
					
					Store.set_state("game", GameConstants.GAME_IN_PROGRESS)


func _ready():
	Store.state_changed.connect(_on_store_state_changed)


func _unhandled_input(event) -> void:
	if event.is_action_released("clear_selection"):
		Store.set_state(GameConstants.STORE_KEYS.SELECTED_SUMMONING_AREA, null)
