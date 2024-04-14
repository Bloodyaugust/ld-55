extends Control

@onready var _resources: Label = %ResourcesLabel

func _on_state_changed(state_key: String, substate: Variant) -> void:
	match state_key:
		GameConstants.STORE_KEYS.RESOURCES:
			_resources.text = "Monies: %.f" % substate


func _ready():
	Store.state_changed.connect(self._on_state_changed)

