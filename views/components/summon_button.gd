extends VBoxContainer

signal pressed

var data: DemonData

@onready var _button: TextureButton = %TextureButton
@onready var _cost: Label = %Cost
@onready var _name: Label = %Name


func _on_store_state_update(state_key: String, _substate: Variant) -> void:
	if is_visible_in_tree():
		match state_key:
			GameConstants.STORE_KEYS.RESOURCES:
				_button.disabled = Store.state[GameConstants.STORE_KEYS.RESOURCES][GameConstants.TEAM.PLAYER]["total"] < data.cost
				
				if _button.disabled:
					modulate = Color.DIM_GRAY
				else:
					modulate = Color.WHITE


func _ready():
	Store.state_changed.connect(_on_store_state_update)
	_button.pressed.connect(func(): pressed.emit())
	
	_cost.text = String.num(data.cost, 0)
	_name.text = data.name
