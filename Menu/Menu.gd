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
@export var checkbtn_turn: CheckButton
@export var checkbtn_algo: CheckButton
@export var button_play: Button

var cells: int = 15
var p2_turn: bool = false
var pruning: bool = false

func _ready() -> void:
	label_cells.text = str(cells)
	slider_cells.value = cells
	checkbtn_turn.button_pressed = p2_turn
	checkbtn_algo.button_pressed = pruning
	
	slider_cells.value_changed.connect(_on_slider_changed)
	checkbtn_turn.toggled.connect(_on_checkbtn_turn_toggled)
	checkbtn_algo.toggled.connect(_on_checkbtn_algo_toggled)
	button_play.pressed.connect(_on_play_pressed)
	
	button_play.grab_focus()

func _on_slider_changed(value: int) -> void:
	cells = value
	label_cells.text = str(value)

func _on_checkbtn_turn_toggled(value: bool) -> void:
	p2_turn = value

func _on_checkbtn_algo_toggled(value: bool) -> void:
	pruning = value

func _on_play_pressed() -> void:
	var game_scene: PackedScene = load(GAME_PATH)
	var game: GameLoop = game_scene.instantiate()
	game.cells_max = cells
	game.p2_turn = p2_turn
	game.init_turn = p2_turn
	game.pruning = pruning
	get_parent().add_child(game)
	queue_free()
