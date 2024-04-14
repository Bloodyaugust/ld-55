extends Node2D

class_name Projectile

const projectile_speed: float = 1000.0
const ai_texture: Texture2D = preload("res://sprites/projectile_red.png")
const player_texture: Texture2D = preload("res://sprites/projectile_blue.png")

@onready var sprite: Sprite2D = %Sprite2D

var team: GameConstants.TEAM
var damage: float
var damage_type: GameConstants.DAMAGE_TYPE
var nav_target: Variant


func _attack() -> void:
	nav_target.damage(damage, damage_type)


# Called when the node enters the scene tree for the first time.
func _ready():
	if team == GameConstants.TEAM.AI:
		sprite.texture = ai_texture
	else:
		sprite.texture = player_texture


func _physics_process(delta):
	if GDUtil.reference_safe(nav_target):
		var _move_direction: Vector2 = global_position.direction_to(nav_target.global_position)

		if global_position.distance_to(nav_target.global_position) <= projectile_speed * delta:
			_attack()
			queue_free()
		else:
			translate(_move_direction * projectile_speed * delta)
			look_at(nav_target.global_position)
	else:
		queue_free()
