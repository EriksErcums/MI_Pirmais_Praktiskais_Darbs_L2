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
const TREE_DEPTH: int = 4
const MIN_WAIT_MSEC: int = 750
# Used diretcly in await, which takes seconds instead
const BOT_SELECT_SEC: float = 0.25

# Input
var init_turn: bool = false
var pruning: bool = false
var cells_max: int = 15

# Game state
var p2_turn: bool = false
var game_tree: GameTree
var state: State
var cur_cell: Cell
var cells: Array[Cell]
var algo: Algorithms
var tree_thread: Thread
# https://docs.godotengine.org/en/stable/tutorials/performance/using_multiple_threads.html


# Init
func _ready() -> void:
	algo = Algorithms.new()
	tree_thread = Thread.new()
	p2_turn = init_turn
	state = State.new()
	state.nums.resize(cells_max)
	cells.resize(cells_max)
	
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
		cells[i] = cell
	
	assign_turn()

func _exit_tree() -> void:
	if tree_thread.is_alive(): tree_thread.wait_to_finish()
	if game_tree:
		game_tree.free_states()
		game_tree.free()

func _create_tree() -> GameTree:
	var _game_tree: GameTree = GameTree.new(state)
	if TREE_DEPTH > 0: _game_tree.build_tree(0, TREE_DEPTH, p2_turn)
	return _game_tree


# --- Commands ---
func assign_turn() -> void:
	lb_score_p1.text = str(state.p1_score)
	lb_score_p2.text = str(state.p2_score)
	if p2_turn:
		# Bot turn
		lb_flavor.text = P2_TURN_STR
		# Blocks the board
		mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED
		focus_behavior_recursive = Control.FOCUS_BEHAVIOR_DISABLED
		
		if cells.size() > 1:
			var start_msec: int = Time.get_ticks_msec()
			tree_thread.start(_create_tree)
			while tree_thread.is_alive(): await get_tree().physics_frame
			if game_tree:
				game_tree.free_states()
				game_tree.free()
			game_tree = tree_thread.wait_to_finish()
			#await get_tree().physics_frame
			
			tree_thread.start(algo.best_move.bind(game_tree, 4, pruning))
			while tree_thread.is_alive(): await get_tree().physics_frame
			var move: Vector2i = tree_thread.wait_to_finish()
			
			var diff: int = Time.get_ticks_msec() - start_msec
			if diff < MIN_WAIT_MSEC:
				var delay: float = (MIN_WAIT_MSEC - diff) * 0.001
				await get_tree().create_timer(delay).timeout
			print("Time per cell: ", algo.time_per_cell)
			print("Time total: ", algo.time_total)
			print("Time avg: ", algo.time_avg)
			print("Iterations: ", algo.iterations)
			
			cells[move.x].modulate = Color.GREEN
			await get_tree().create_timer(BOT_SELECT_SEC).timeout
			cells[move.y].modulate = Color.GREEN
			await get_tree().create_timer(BOT_SELECT_SEC).timeout
			cells[move.x].modulate = Color.WHITE
			_pop_cells(cells[move.x], cells[move.y])
		else:
			await get_tree().create_timer(MIN_WAIT_MSEC).timeout
			_pop_cell()
		# Unblocks the board
		mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_INHERITED
		focus_behavior_recursive = Control.FOCUS_BEHAVIOR_INHERITED
	else:
		# Player turn
		lb_flavor.text = P1_TURN_STR
		cells[0].grab_focus()

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
	state.process_turn(-1, -1, p2_turn)
	finish_game()

# Use this for finishing bot's move
func _pop_cells(cell1: Cell, cell2: Cell) -> void:
	# Process & clean
	state.process_turn(cell1.id, cell2.id, p2_turn)
	cells.remove_at(cell2.id)
	cell2.queue_free()
	
	# Update visually
	for i: int in cells.size():
		var c: Cell = cells[i]
		c.id = i
		c.modulate = Color.WHITE
	cell1.text = str(state.nums[cell1.id])
	cell1.button_pressed = false
	cell1.modulate = COLOR_SHINE
	
	# Rebind neighbors
	var left_id: int = cell1.id-1
	if left_id > -1:
		cells[left_id].right = cell1
		cell1.left = cells[left_id]
	var right_id: int = cell1.id+1
	if right_id < cells.size():
		cell1.right = cells[right_id]
		cells[right_id].left = cell1
	
	p2_turn = !p2_turn
	assign_turn.call_deferred()
	
