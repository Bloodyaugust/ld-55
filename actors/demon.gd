extends Node2D
class_name Demon

enum DEMON_STATES {
	IDLE,
	MOVING,
	ATTACKING
}

@export var data: DemonData
@export var initial_nav_target: Node2D
@export var team: GameConstants.TEAM

var _attack_cooldown: float
var _current_nav_target: Variant
var _health: float
var _state: DEMON_STATES


func damage(amount: float) -> void:
	_health -= amount
	
	if _health <= 0.0:
		queue_free()


func set_nav_target(new_target: Node2D) -> void:
	_current_nav_target = new_target


func _attack(attack_target: Demon) -> void:
	attack_target.damage(data.damage)
	
	_attack_cooldown = data.attack_interval


func _ready():
	_health = data.health
	_current_nav_target = initial_nav_target


func _physics_process(delta):
	match _state:
		DEMON_STATES.IDLE:
			pass
		DEMON_STATES.MOVING:
			if GDUtil.reference_safe(_current_nav_target):
				if is_equal_approx(global_position.distance_to(_current_nav_target.global_position), 0.0):
					_current_nav_target = null
				else:
					var _move_direction: Vector2 = global_position.direction_to(_current_nav_target.global_position)

					if global_position.distance_to(_current_nav_target.global_position) <= data.move_speed * delta:
						global_position = Vector2(_current_nav_target.global_position)
					else:
						translate(_move_direction * data.move_speed * delta)
		DEMON_STATES.ATTACKING:
			pass

func _process(delta):
	_attack_cooldown = clamp(_attack_cooldown - delta, 0.0, data.attack_interval)
	var _group_nodes := get_tree().get_nodes_in_group(GameConstants.DEMONS_GROUP)
	var _demons: Array[Demon]
	_demons.assign(_group_nodes)
	var _enemy_demons: Array[Demon] = _demons.filter(func (checking_demon: Demon): return team != checking_demon.team)
	var _enemy_demons_in_range: Array[Demon] = _enemy_demons.filter(func (checking_demon: Demon): return global_position.distance_to(checking_demon.global_position) <= data.attack_range)
	
	match _state:
		DEMON_STATES.IDLE:
			if _enemy_demons_in_range.size() > 0:
				_state = DEMON_STATES.ATTACKING
			elif GDUtil.reference_safe(_current_nav_target):
				_state = DEMON_STATES.MOVING
		DEMON_STATES.MOVING:
			if _enemy_demons_in_range.size() > 0:
				_state = DEMON_STATES.ATTACKING
		DEMON_STATES.ATTACKING:
			if _enemy_demons_in_range.size() == 0:
				_state = DEMON_STATES.IDLE
			elif is_equal_approx(_attack_cooldown, 0.0):
				_attack(_enemy_demons_in_range.front())
