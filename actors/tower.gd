extends Node2D

const ai_sprite: Texture2D = preload("res://sprites/tower_red.png")
const player_sprite: Texture2D = preload("res://sprites/tower_blue.png")

@export var data: TowerData
@export var team: GameConstants.TEAM

@onready var _health_bar: ProgressBar = %HealthBar
@onready var _sprite: Sprite2D = %Sprite2D

var _attack_cooldown: float
var _dead: bool = false
var _health: float


func damage(amount: float, _type: GameConstants.DAMAGE_TYPE) -> void:
	if !_dead:
		_health -= amount
		_health_bar.value = _health / data.health
		
		if _health <= 0.0:
			_dead = true
			GameController.tower_destroyed(team)

func _attack(attack_target: Node2D) -> void:
	attack_target.damage(data.damage, data.damage_type)
	
	_attack_cooldown = data.attack_interval


func _ready():
	_health = data.health
	_health_bar.value = _health / data.health
	_sprite.texture = ai_sprite if team == GameConstants.TEAM.AI else player_sprite
	
func _process(delta):
	_attack_cooldown = clamp(_attack_cooldown - delta, 0.0, data.attack_interval)
	var _damageable_group_nodes := get_tree().get_nodes_in_group(GameConstants.DAMAGEABLE_GROUP)
	
	var _damageables: Array[Node2D] = []
	_damageables.assign(_damageable_group_nodes)

	var _enemy_damageables: Array[Node2D] = _damageables.filter(func (checking_damageable: Node2D): return team != checking_damageable.team)
	var _enemy_damageables_in_range: Array[Node2D] = _enemy_damageables.filter(func (checking_damageable: Node2D): return global_position.distance_to(checking_damageable.global_position) <= data.attack_range)
	
	if is_equal_approx(_attack_cooldown, 0.0) and _enemy_damageables_in_range.size() > 0:
		_attack(_enemy_damageables_in_range.front())
	
	
	
