extends VBoxContainer

signal pressed

var data: DemonData

@onready var _button: TextureButton = %TextureButton
@onready var _cost: Label = %Cost
@onready var _name: Label = %Name


func _ready():
	_button.pressed.connect(func(): pressed.emit())
	
	_cost.text = "PLACEHOLDER COST"
	_name.text = data.name
