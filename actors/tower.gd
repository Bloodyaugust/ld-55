extends Node2D

@export var data: TowerData
@export var team: GameConstants.TEAM

@onready var _health_bar: ProgressBar = %HealthBar

var _health: float


func damage(amount: float) -> void:
	_health -= amount
	_health_bar.value = _health / data.health
	
	if _health <= 0.0:
		queue_free()


func _ready():
	_health = data.health
	_health_bar.value = _health / data.health


func _process(delta):
	pass
