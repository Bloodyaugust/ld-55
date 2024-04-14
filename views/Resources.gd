extends Control

@onready var _resources: Label = %ResourcesLabel

func _on_state_changed(state_key: String, substate: Variant) -> void:
	match state_key:
		GameConstants.STORE_KEYS.RESOURCES:
			_resources.text = "Monies: {total}({rate})".format({
				"total": "%.f" % Store.state[GameConstants.STORE_KEYS.RESOURCES][GameConstants.TEAM.PLAYER]["total"],
				"rate": "%.f" % Store.state[GameConstants.STORE_KEYS.RESOURCES][GameConstants.TEAM.PLAYER]["rate"]
			})


func _ready():
	Store.state_changed.connect(self._on_state_changed)

