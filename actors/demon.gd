extends Node2D
class_name Demon

@export var data: DemonData
@export var initial_nav_target: Node2D

var _current_nav_target: Variant
var _health: float


func set_nav_target(new_target: Node2D) -> void:
	_current_nav_target = new_target


func _ready():
	_health = data.health
	_current_nav_target = initial_nav_target


func _physics_process(delta):
	if GDUtil.reference_safe(_current_nav_target):
		if is_equal_approx(global_position.distance_to(_current_nav_target.global_position), 0.0):
			_current_nav_target = null
		else:
			var _move_direction: Vector2 = global_position.direction_to(_current_nav_target.global_position)
			
			if global_position.distance_to(_current_nav_target.global_position) <= data.move_speed * delta:
				global_position = Vector2(_current_nav_target.global_position)
			else:
				translate(_move_direction * data.move_speed * delta)
