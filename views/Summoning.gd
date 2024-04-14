extends Control

const summon_button_scene: PackedScene = preload("res://views/components/summon_button.tscn")

@onready var _summon_buttons_container: Control = %SummonButtonsContainer


func _on_summon_button_pressed(demon: DemonData) -> void:
	GameController.queue_demon(Store.state[GameConstants.STORE_KEYS.SELECTED_SUMMONING_AREA], demon)


func _on_state_changed(state_key: String, substate: Variant) -> void:
	match state_key:
		GameConstants.STORE_KEYS.SELECTED_SUMMONING_AREA:
			visible = substate != null


func _ready():
	Store.state_changed.connect(self._on_state_changed)
	
	for demon: DemonData in GameConstants.DEMON_DATA.values():
		var _new_button: Control = summon_button_scene.instantiate()

		_new_button.pressed.connect(func (): _on_summon_button_pressed(demon))
		_new_button.data = demon
		_summon_buttons_container.add_child(_new_button)
