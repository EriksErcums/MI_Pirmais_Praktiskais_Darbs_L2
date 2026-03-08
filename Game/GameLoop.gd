extends Control

signal finished(won: bool)

# Node refs
@export var lb_flavor: RichTextLabel
@export var lb_score_p1: Label
@export var lb_score_p2: Label
@export var scroll_container: ScrollContainer
@export var container: HBoxContainer

# Consts
const MIN_NUM: int = 1
const MAX_NUM: int = 6
const CELL_SCENE: PackedScene = preload("res://Cell/Cell.tscn")
const P1_TURN_STR: String = "Make your move"
const P2_TURN_STR: String = "[wave amp=20.0 freq=5.0]...[/wave]"
const P1_WON_STR: String = "You won!"
const P2_WON_STR: String = "You lost!"
const DRAFT_STR: String = "Draft!"
const COLOR_SHINE: Color = Color(4.5, 4.5, 4.5)

# Data
var turn: bool = true
var init_turn: bool = true
var pruning: bool = false
var cells_max: int = 15

var game_tree: GameTree
var state: State
var cur_cell: Cell
var cells: Array[Cell]



# Init
func _ready() -> void:
	state = State.new()
	state.nums.resize(cells_max)
	var cell_prev: Cell = null
	for i: int in cells_max:
		state.nums[i] = randi_range(MIN_NUM, MAX_NUM)
		var cell: Cell = CELL_SCENE.instantiate()
		cell.id = i
		cell.text = str(state.nums[i])
		cell.pressed.connect(_on_cell_clicked.bind(cell))
		container.add_child(cell)
		if cell_prev:
			cell.left = cell_prev
			cell_prev.right = cell
		cell_prev = cell
		cells.append(cell)
		
	
	game_tree = GameTree.new(state, -1)
	assign_turn()



# --- Commands ---
func assign_turn() -> void:
	lb_score_p1.text = str(state.p1_score)
	lb_score_p2.text = str(state.p2_score)
	if turn:
		# Player turn
		lb_flavor.text = P1_TURN_STR
		cells[0].grab_focus()
	else:
		# Bot turn
		lb_flavor.text = P2_TURN_STR
		# Block the gameboard and make the bot move
	turn = !turn

func finish_game() -> void:
	finished.emit(state.p1_score > state.p2_score)
	scroll_container.queue_free()
	lb_score_p1.text = str(state.p1_score)
	lb_score_p2.text = str(state.p2_score)
	if state.p1_score > state.p2_score:
		lb_flavor.text = P1_WON_STR
	elif state.p1_score < state.p2_score:
		lb_flavor.text = P2_WON_STR
	else:
		lb_flavor.text = DRAFT_STR

func light_cells(at: int) -> void:
	for i: int in cells.size():
		var c: Cell = cells[i]
		if i == at-1 || i == at+1:
			c.modulate = COLOR_SHINE
			continue
		if i == at: continue
		c.modulate = Color.WEB_GRAY
	var cell: Cell = cells[at]
	if cell.left: cell.left.grab_focus()
	elif cell.right: cell.right.grab_focus()



# --- Core logic ---
func _on_cell_clicked(cell: Cell) -> void:
	if cells.size() == 1:
		_pop_cell()
		return
	
	# 1st cell
	var is_invalid: bool = cur_cell != null && cur_cell != cell.left && cur_cell != cell.right
	if cur_cell == null || is_invalid && cur_cell != cell:
		if is_invalid: cur_cell.button_pressed = false
		cur_cell = cell
		cell.modulate = Color.WHITE
		light_cells(cell.id)
		return
	# 2nd cell // Selected again
	if cur_cell == cell:
		cur_cell = null
		for c: Cell in cells: c.modulate = Color.WHITE
		return
	
	# Selecting second cell // move
	_pop_cells(cur_cell, cell)
	cur_cell = null

# Use this to finish bot's turn with 1 cell
func _pop_cell() -> void:
	_process_turn(state, -1, -1, turn)
	finish_game()

# Use this for finishing bot's move
func _pop_cells(cell1: Cell, cell2: Cell) -> void:
	# Process & clean
	_process_turn(state, cell1.id, cell2.id, turn)
	cells.remove_at(cell2.id)
	cell2.queue_free()
	
	# Update visually
	cell1.button_pressed = false
	for i: int in cells.size():
		var c: Cell = cells[i]
		c.id = i
		c.modulate = Color.WHITE
	var cap_id: int = min(cell1.id, cells.size()-1)
	cell1.text = str(state.nums[cap_id])
	cell1.modulate = COLOR_SHINE
	
	# Rebind neighbors
	var left_id: int = cell1.id - 1
	if left_id >= 0:
		cells[left_id].right = cell1
		cell1.left = cells[left_id]
	else:
		cell1.left = null

	var right_id: int = cell1.id + 1
	if right_id < cells.size():
		cell1.right = cells[right_id]
		cells[right_id].left = cell1
	else:
		cell1.right = null
		
	assign_turn()

# Use this for simulating turns
func _process_turn(_state: State, pos1: int, pos2: int, _turn: bool) -> void:
	# Player erased last cell
	if pos1 == -1 && pos2 == -1:
		if turn: _state.p1_score -= 1
		else: _state.p2_score -= 1
		_state.nums.clear()
		return
	
	# Player merged 2 cells into 1
	var sum: int = state.nums[pos1] + state.nums[pos2]
	var score: int = 2 if sum == 7 else 1
	
	if sum > 6: _state.nums[pos1] = sum - 6
	else: _state.nums[pos1] = sum
	_state.nums.remove_at(pos2)
	
	if _turn: _state.p2_score += score
	else: _state.p1_score += score
