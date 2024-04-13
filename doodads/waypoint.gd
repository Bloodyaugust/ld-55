extends Node2D

enum STATE {
	CAPTURED,
	CAPTURING,
	CONTESTED
}

const CAPTURE_THRESHOLD: float = 5.0

@export var nav_target_ai: Node2D
@export var nav_target_player: Node2D

@onready var _area2D: Area2D = %Area2D

var _team: GameConstants.TEAM = GameConstants.TEAM.NEUTRAL
var _demons_in_waypoint: Array[Demon]
var _state: STATE = STATE.CAPTURED
var _capture_progress: float = 0.0

func _on_area2D_exited(exiting_area: Area2D) -> void:
	var _demon: Demon = exiting_area.get_parent()
	_demons_in_waypoint.erase(_demon)
	_determine_state()
	
	if _state == STATE.CAPTURED:
		for demon: Demon in _demons_in_waypoint:
			route_demon(demon) 

func _on_area2D_entered(entering_area: Area2D) -> void:
	var _demon: Demon = entering_area.get_parent()
	_demons_in_waypoint.append(_demon)
	_determine_state()
	
	if _state == STATE.CAPTURED:
		route_demon(_demon)
				
				
func route_demon(demon: Demon) -> void:
	match demon.team:
		GameConstants.TEAM.AI:
			demon.set_nav_target(nav_target_ai)
		GameConstants.TEAM.PLAYER:
			demon.set_nav_target(nav_target_player)
	

func _determine_state() -> void:
	var _team_counts = _demons_in_waypoint.reduce(func(accu, demon: Demon): 
		accu[demon.team] = accu[demon.team] + 1
		return accu
	, { GameConstants.TEAM.AI: 0, GameConstants.TEAM.PLAYER: 0})

	if _team_counts[GameConstants.TEAM.AI] == 0 and _team_counts[GameConstants.TEAM.PLAYER] == 0:
		_state = STATE.CAPTURED
	elif _team_counts[GameConstants.TEAM.AI] >= 1 and _team_counts[GameConstants.TEAM.PLAYER] >= 1:
		_state = STATE.CONTESTED
		_capture_progress = 0.0
	else:
		_state = STATE.CAPTURING

func _process(delta) -> void:
	if _state == STATE.CAPTURING:
		_capture_progress += _demons_in_waypoint.size() * delta
	
	if _capture_progress >= CAPTURE_THRESHOLD:
		for demon: Demon in _demons_in_waypoint:
			route_demon(demon)
		_team = _demons_in_waypoint.front().team
		_capture_progress = 0.0
		_state = STATE.CAPTURED


func _ready():
	_area2D.area_entered.connect(_on_area2D_entered)
	_area2D.area_exited.connect(_on_area2D_exited)
