extends Control

const summon_button_scene: PackedScene = preload("res://views/components/summon_button.tscn")
const queued_summon_scene: PackedScene = preload("res://views/components/queued_summon.tscn")

@onready var _summon_buttons_container: Control = %SummonButtonsContainer
@onready var _queued_summons_container: Control = %QueuedSummonsContainer


func _evaluate_summon_queue() -> void:
		if visible:
			var _summoning_area_queue: Array = Store.state[GameConstants.STORE_KEYS.SUMMONING_QUEUE].filter(func(queued_summon): return queued_summon.summoning_area == Store.state[GameConstants.STORE_KEYS.SELECTED_SUMMONING_AREA])
			var _queued_summons_data: Dictionary = _summoning_area_queue.reduce(func(accu, queued_summon):
				if accu.has(queued_summon.demon):
					accu[queued_summon.demon] = accu[queued_summon.demon] + 1
				else:
					accu[queued_summon.demon] = 1
					
				return accu
				, {})
			
			GDUtil.queue_free_children(_queued_summons_container)
			
			if _queued_summons_data.keys().size() > 0:
				for demon in _queued_summons_data.keys():
					var _new_queued_summon_component: Control = queued_summon_scene.instantiate()
					
					_new_queued_summon_component.demon = demon
					_new_queued_summon_component.count = _queued_summons_data[demon]
					_queued_summons_container.add_child(_new_queued_summon_component)
			else:
				var _empty_queue_label: Label = Label.new()
				
				_empty_queue_label.text = "No summons queued"
				_queued_summons_container.add_child(_empty_queue_label)


func _on_summon_button_pressed(demon: DemonData) -> void:
	GameController.queue_demon(Store.state[GameConstants.STORE_KEYS.SELECTED_SUMMONING_AREA], demon)


func _on_state_changed(state_key: String, substate: Variant) -> void:
	match state_key:
		GameConstants.STORE_KEYS.SELECTED_SUMMONING_AREA:
			visible = substate != null
			_evaluate_summon_queue()
		GameConstants.STORE_KEYS.SUMMONING_QUEUE:
			_evaluate_summon_queue()


func _ready():
	Store.state_changed.connect(self._on_state_changed)
	
	var _empty_queue_label: Label = Label.new()

	_empty_queue_label.text = "No summons queued"
	_queued_summons_container.add_child(_empty_queue_label)
	
	for demon: DemonData in GameConstants.DEMON_DATA.values():
		var _new_button: Control = summon_button_scene.instantiate()

		_new_button.pressed.connect(func (): _on_summon_button_pressed(demon))
		_new_button.data = demon
		_summon_buttons_container.add_child(_new_button)
