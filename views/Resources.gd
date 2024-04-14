extends Control

@onready var _resources: Label = %ResourcesLabel

func _on_state_changed(state_key: String, _substate: Variant) -> void:
	match state_key:
		GameConstants.STORE_KEYS.RESOURCES:
			_resources.text = "Resources: {total}(+{rate}/sec)".format({
				"total": "%04d" % Store.state[GameConstants.STORE_KEYS.RESOURCES][GameConstants.TEAM.PLAYER]["total"],
				"rate": "%02d" % Store.state[GameConstants.STORE_KEYS.RESOURCES][GameConstants.TEAM.PLAYER]["rate"]
			})


func _ready():
	Store.state_changed.connect(self._on_state_changed)

