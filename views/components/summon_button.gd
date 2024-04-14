extends Control

signal pressed

var data: DemonData

@onready var _texture: TextureRect = %TextureRect
@onready var _description: Label = %Description

var _disabled: bool = false


func _on_gui_input(input_event: InputEvent) -> void:
	if !_disabled and input_event.is_action_released("set_selection"):
		pressed.emit()


func _on_store_state_update(state_key: String, _substate: Variant) -> void:
	if is_visible_in_tree():
		match state_key:
			GameConstants.STORE_KEYS.RESOURCES:
				_disabled = Store.state[GameConstants.STORE_KEYS.RESOURCES][GameConstants.TEAM.PLAYER]["total"] < data.cost
				
				if _disabled:
					modulate = Color.DIM_GRAY
				else:
					modulate = Color.WHITE


func _ready():
	Store.state_changed.connect(_on_store_state_update)
	gui_input.connect(_on_gui_input)
	_texture.texture = data.sprite
	
	_description.text = "{name}\r\nCost: {cost}\r\nHealth: {health}\r\nDamage: {dps}/sec\r\nAttack Type: {attack}\r\nArmor Type: {armor}".format({
		"name": data.name,
		"cost": data.cost,
		"health": data.health,
		"dps": "%1.f" % (data.damage / data.attack_interval),
		"attack": GameConstants.DAMAGE_TYPE_NAMES[data.damage_type],
		"armor": GameConstants.ARMOR_TYPE_NAMES[data.armor_type]
	})
