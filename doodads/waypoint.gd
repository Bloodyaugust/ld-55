extends Node2D

@export var nav_target_ai: Node2D
@export var nav_target_player: Node2D

@onready var _area2D: Area2D = %Area2D

func _on_area2D_entered(entering_area: Area2D) -> void:
	var _entering_demon: Demon = entering_area.get_parent()
	
	match _entering_demon.team:
		GameConstants.TEAM.AI:
			_entering_demon.set_nav_target(nav_target_ai)
		GameConstants.TEAM.PLAYER:
			_entering_demon.set_nav_target(nav_target_player)

func _ready():
	_area2D.area_entered.connect(_on_area2D_entered)
