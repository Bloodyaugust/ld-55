extends Control

@onready var _summoning_timer: Label = %SummoningTimerLabel


func _on_state_changed(state_key: String, substate: Variant):
	match state_key:
		GameConstants.STORE_KEYS.TIME_TO_SUMMONING:
			_summoning_timer.text = "Time to summoning: %02d seconds" % substate


func _ready():
	Store.state_changed.connect(self._on_state_changed)

