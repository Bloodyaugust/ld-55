extends Control

var count: int
var demon: DemonData

@onready var _label: Label = %Label
@onready var _texture: TextureRect = %TextureRect


func _ready():
	_label.text = "{count}x {name}".format({
		"count": "%02d" % count,
		"name": demon.name
	})
	_texture.texture = demon.player_sprite

