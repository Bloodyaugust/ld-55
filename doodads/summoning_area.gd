extends Node2D

const demon_scene: PackedScene = preload("res://actors/demon.tscn")


@export var nav_target: Node2D
@export var team: GameConstants.TEAM

@onready var _area2D: Area2D = %Area2D

var _hovered: bool = false
var _selected: bool = false


func _draw():
	if _selected:
		draw_arc(Vector2.ZERO, 150.0, 0.0, 2.0 * PI, 32, Color.GREEN_YELLOW)


func _on_area2D_input_event(_viewport: Node, event: InputEvent, _shape_index: int) -> void:
	if event.is_action_released("pick_summoning_area") and team == GameConstants.TEAM.PLAYER:
		Store.set_state(GameConstants.STORE_KEYS.SELECTED_SUMMONING_AREA, self)


func _on_mouse_entered() -> void:
	_hovered = true
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	
	

func _on_mouse_exited() -> void:
	_hovered = false
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)


func _on_store_state_changed(state_key: String, substate: Variant) -> void:
	match state_key:
		GameConstants.STORE_KEYS.SELECTED_SUMMONING_AREA:
			_selected = self == substate


func _ready():
	Store.state_changed.connect(_on_store_state_changed)
	_area2D.input_event.connect(_on_area2D_input_event)
	_area2D.mouse_entered.connect(_on_mouse_entered)
	_area2D.mouse_exited.connect(_on_mouse_exited)


func _process(_delta):
	queue_redraw()
