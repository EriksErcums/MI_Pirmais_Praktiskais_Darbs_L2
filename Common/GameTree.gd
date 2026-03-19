class_name GameTree extends RefCounted

const INF: int = 1 << 30

var states: Array[State]
var verticies: Dictionary[int, PackedInt32Array]

func _init(init_state: State, depth: int = -1, is_p1_turn: bool = true) -> void:
	states = []
	verticies = {}
	var root_state = init_state.clone()
	states.append(root_state)
	if depth > 0:
		build_tree(0, depth, is_p1_turn)

func build_tree(state_id: int, depth: int, is_p1_turn: bool) -> void:
	if depth == 0:
		return
	var state = states[state_id]
	# built-in generate_children() //////////////////
	var children = []
	if state.nums.size() > 1:
		for i in range(state.nums.size() - 1):
			var child = state.clone()
			child.process_turn(i, i + 1, not is_p1_turn)
			children.append(child)
	verticies[state_id] = []
	for child in children:
		var child_id = states.size()
		states.append(child)
		verticies[state_id].append(child_id)
		build_tree(child_id, depth - 1, not is_p1_turn)


func add_state(state: State) -> void:
	states.append(state)

func add_vertice(from_id: int, to_id: int) -> void:
	if not verticies.has(from_id):
		verticies[from_id] = []
	verticies[from_id].append(to_id)
