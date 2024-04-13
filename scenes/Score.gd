extends Control

@onready var _main_menu: Button = %MainMenuScore
@onready var _winner: Label = %WinnerLabel


func _on_main_menu_pressed() -> void:
	ViewController.set_client_view(ViewController.CLIENT_VIEWS.MAIN_MENU)


func _on_state_changed(state_key: String, substate: Variant) -> void:
	match state_key:
		"winner":
			var _winner_name: String = "Player" if substate == GameConstants.TEAM.PLAYER else "AI"
			_winner.text = "%s won!" % _winner_name


func _ready():
	Store.state_changed.connect(self._on_state_changed)
	_main_menu.pressed.connect(_on_main_menu_pressed)

	ViewController.register_view(ViewController.CLIENT_VIEWS.SCORE, self)
