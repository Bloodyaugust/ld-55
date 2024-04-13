extends Node2D

const demon_scene: PackedScene = preload("res://actors/demon.tscn")


@export var nav_target: Node2D
@export var team: GameConstants.TEAM

@onready var _area2D: Area2D = %Area2D

var _selected: bool = false


func _draw():
	if _selected:
		draw_arc(Vector2.ZERO, 50.0, 0.0, 2.0 * PI, 32, Color.GREEN_YELLOW)


func _on_area2D_input_event(_viewport: Node, event: InputEvent, _shape_index: int) -> void:
	if event.is_action_released("pick_summoning_area") and team == GameConstants.TEAM.PLAYER:
		Store.set_state(GameConstants.STORE_KEYS.SELECTED_SUMMONING_AREA, self)


func _on_store_state_changed(state_key: String, substate: Variant) -> void:
	match state_key:
		GameConstants.STORE_KEYS.SELECTED_SUMMONING_AREA:
			_selected = self == substate


func _ready():
	Store.state_changed.connect(_on_store_state_changed)
	_area2D.input_event.connect(_on_area2D_input_event)


func _process(_delta):
	queue_redraw()
