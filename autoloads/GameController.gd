extends Node

const battlefield_scene: PackedScene = preload("res://scenes/battlefield.tscn")

var _current_game_scene: Variant = null


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
