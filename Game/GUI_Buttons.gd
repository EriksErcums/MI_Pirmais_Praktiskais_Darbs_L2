extends HBoxContainer

const GameLoop: Script = preload("res://Game/GameLoop.gd")
const Menu: Script = preload("res://Menu/Menu.gd")
const MENU_PATH: String = "res://Menu/Menu.tscn"

@export var game: GameLoop
@export var btn_menu: Button
@export var btn_restart: Button

func _ready() -> void:
	get_tree().current_scene = game
	btn_menu.pressed.connect(_on_menu)
	btn_restart.pressed.connect(_on_restart)
	game.finished.connect(_on_finished)

func _on_menu() -> void:
	var menu_scene: PackedScene = load(MENU_PATH)
	var menu: Menu = menu_scene.instantiate()
	menu.cells = game.cells_max
	menu.turn = game.init_turn
	menu.pruning = game.pruning
	game.get_parent().add_child(menu)
	game.queue_free()

func _on_restart() -> void:
	get_tree().reload_current_scene()

func _on_finished(_won: bool) -> void:
	btn_restart.grab_focus()
