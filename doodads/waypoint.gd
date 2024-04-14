extends Node2D

class_name Waypoint

enum STATE {
	CAPTURED,
	CAPTURING,
	CONTESTED
}

const BASE_SCALE: Vector2 = Vector2(0.20, 0.20)
const CAPTURE_THRESHOLD: float = 5.0

@export var nav_target_ai: Node2D
@export var nav_target_player: Node2D
@export var resource_rate: float

@onready var _area2D: Area2D = %Area2D
@onready var _progress_bar: ProgressBar = %ProgressBar
@onready var _team_label: Label = %TeamLabel
@onready var _info: Label = %Info

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


func _update_team_label() -> void:
	match _team:
		GameConstants.TEAM.AI:
			_team_label.text = "AI"
		GameConstants.TEAM.PLAYER:
			_team_label.text = "Player"
		GameConstants.TEAM.NEUTRAL:
			_team_label.text = "Neutral"


				
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
	elif (_team_counts[GameConstants.TEAM.AI] > 0 and _team == GameConstants.TEAM.AI) or (_team_counts[GameConstants.TEAM.PLAYER] > 0 and _team == GameConstants.TEAM.PLAYER):
		_state = STATE.CAPTURED
	else:
		_state = STATE.CAPTURING

func _process(delta) -> void:
	if _state == STATE.CAPTURING:
		_capture_progress = clamp(_capture_progress + _demons_in_waypoint.size() * delta, 0.0, CAPTURE_THRESHOLD)
	
	if _capture_progress >= CAPTURE_THRESHOLD:
		for demon: Demon in _demons_in_waypoint:
			route_demon(demon)
		_team = _demons_in_waypoint.front().team
		_capture_progress = 0.0
		_state = STATE.CAPTURED
		_update_team_label()
		GameController.waypoint_captured()
	
	_progress_bar.value = _capture_progress / CAPTURE_THRESHOLD


func _ready():
	_area2D.area_entered.connect(_on_area2D_entered)
	_area2D.area_exited.connect(_on_area2D_exited)
	_update_team_label()
	_info.text = "+%1.f Resources/sec" % resource_rate
	%Sprite2D.scale = BASE_SCALE + (Vector2(resource_rate, resource_rate) / 75)
