extends Node2D

const ai_sprite: Texture2D = preload("res://sprites/tower_red.png")
const player_sprite: Texture2D = preload("res://sprites/tower_blue.png")

@export var data: TowerData
@export var team: GameConstants.TEAM

@onready var _health_bar: ProgressBar = %HealthBar
@onready var _sprite: Sprite2D = %Sprite2D

var _dead: bool = false
var _health: float


func damage(amount: float) -> void:
	if !_dead:
		_health -= amount
		_health_bar.value = _health / data.health
		
		if _health <= 0.0:
			_dead = true
			GameController.tower_destroyed(team)


func _ready():
	_health = data.health
	_health_bar.value = _health / data.health
	_sprite.texture = ai_sprite if team == GameConstants.TEAM.AI else player_sprite
	
