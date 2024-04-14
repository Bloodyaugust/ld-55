extends Node2D
class_name Demon

enum DEMON_STATES {
	IDLE,
	MOVING,
	ATTACKING
}

const PUSH_DISTANCE: float = 50.0

@export var data: DemonData
@export var initial_nav_target: Node2D
@export var team: GameConstants.TEAM

@onready var _health_bar: ProgressBar = %ProgressBar
@onready var _label: Label = %Label

var _attack_cooldown: float
var _current_nav_target: Variant
var _health: float
var _state: DEMON_STATES

const damage_modifier = {
			GameConstants.DAMAGE_TYPE.BLUNT: {
				GameConstants.ARMOR_TYPE.LIGHT: 2.0,
				GameConstants.ARMOR_TYPE.MEDIUM: 1.5,
				GameConstants.ARMOR_TYPE.HEAVY: 0.5
			},
			GameConstants.DAMAGE_TYPE.PIERCING: {
				GameConstants.ARMOR_TYPE.LIGHT: 1.0,
				GameConstants.ARMOR_TYPE.MEDIUM: 1.0,
				GameConstants.ARMOR_TYPE.HEAVY: 2.0
			},
			GameConstants.DAMAGE_TYPE.MAGIC: {
				GameConstants.ARMOR_TYPE.LIGHT: 1.0,
				GameConstants.ARMOR_TYPE.MEDIUM: 1.0,
				GameConstants.ARMOR_TYPE.HEAVY: 1.0
			},
		}


func damage(amount: float, type: GameConstants.DAMAGE_TYPE) -> void:
	var _damage_modifier = damage_modifier[type][data.armor_type]
	_health = clamp(_health - (amount * _damage_modifier), 0.0, data.health)
	_health_bar.value = _health / data.health
	
	if _health <= 0.0:
		queue_free()


func set_nav_target(new_target: Node2D) -> void:
	_current_nav_target = new_target


func _attack(attack_target: Node2D) -> void:
	attack_target.damage(data.damage, data.damage_type)
	
	_attack_cooldown = data.attack_interval


func _ready():
	_health = data.health
	_health_bar.value = _health / data.health
	_label.text = data.name
	_current_nav_target = initial_nav_target


func _physics_process(delta):
	var _demon_group_nodes := get_tree().get_nodes_in_group(GameConstants.DEMONS_GROUP)
	
	var _demons: Array[Demon] = []
	_demons.assign(_demon_group_nodes)
	var _close_demons: Array[Demon] = _demons.filter(func(demon): return demon != self and global_position.distance_to(demon.global_position) <= PUSH_DISTANCE)
	
	if _close_demons.size() > 0:
		var _push_direction: Vector2 = Vector2(randf(), randf())
		for demon in _close_demons:
			_push_direction += global_position - demon.global_position

		translate(_push_direction.normalized() * delta * _close_demons.size() * 15)
	
	match _state:
		DEMON_STATES.IDLE:
			pass
		DEMON_STATES.MOVING:
			if GDUtil.reference_safe(_current_nav_target):
				if is_equal_approx(global_position.distance_to(_current_nav_target.global_position), 0.0):
					_current_nav_target = null
					_state = DEMON_STATES.IDLE
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
	var _damageable_group_nodes := get_tree().get_nodes_in_group(GameConstants.DAMAGEABLE_GROUP)
	
	var _damageables: Array[Node2D] = []
	_damageables.assign(_damageable_group_nodes)

	var _enemy_damageables: Array[Node2D] = _damageables.filter(func (checking_damageable: Node2D): return team != checking_damageable.team)
	var _enemy_damageables_in_range: Array[Node2D] = _enemy_damageables.filter(func (checking_damageable: Node2D): return global_position.distance_to(checking_damageable.global_position) <= data.attack_range)
	
	match _state:
		DEMON_STATES.IDLE:
			if _enemy_damageables_in_range.size() > 0:
				_state = DEMON_STATES.ATTACKING
			elif GDUtil.reference_safe(_current_nav_target):
				_state = DEMON_STATES.MOVING
		DEMON_STATES.MOVING:
			if _enemy_damageables_in_range.size() > 0:
				_state = DEMON_STATES.ATTACKING
		DEMON_STATES.ATTACKING:
			if _enemy_damageables_in_range.size() == 0:
				_state = DEMON_STATES.IDLE
			elif is_equal_approx(_attack_cooldown, 0.0):
				_attack(_enemy_damageables_in_range.front())
