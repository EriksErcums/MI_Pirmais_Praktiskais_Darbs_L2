extends Control

# Imports GameLoop class
# Defining `class_name` in GameLoop script would make it accessible from
# every script, but also polute the global scope
const GameLoop: Script = preload("res://Game/GameLoop.gd")
const GAME_PATH: String = "res://Game/GameLoop.tscn"

# @export let's us modify variable from the editor
# You can get references from scenes you using $<node_path> and get_node()
# functions too, but they are slower and more inconvinient
@export var slider_cells: HSlider
@export var label_cells: Label
@export var checkbutton_turn: CheckButton
@export var checkbutton_algo: CheckButton
@export var button_play: Button

var cells: int = 15
var turn: bool = true
var pruning: bool = false

func _ready() -> void:
	label_cells.text = str(cells)
	slider_cells.value = cells
	checkbutton_turn.button_pressed = turn
	checkbutton_algo.button_pressed = pruning
	
	slider_cells.value_changed.connect(_on_slider_changed)
	checkbutton_turn.toggled.connect(_on_checkbutton_turn_toggled)
	checkbutton_algo.toggled.connect(_on_checkbutton_algo_toggled)
	button_play.pressed.connect(_on_play_pressed)
	
	button_play.grab_focus()

func _on_slider_changed(value: int) -> void:
	cells = value
	label_cells.text = str(value)

func _on_checkbutton_turn_toggled(value: bool) -> void:
	turn = value

func _on_checkbutton_algo_toggled(value: bool) -> void:
	pruning = value

func _on_play_pressed() -> void:
	var game_scene: PackedScene = load(GAME_PATH)
	var game: GameLoop = game_scene.instantiate()
	game.cells_max = cells
	game.turn = turn
	game.init_turn = turn
	game.pruning = pruning
	get_parent().add_child(game)
	queue_free()
