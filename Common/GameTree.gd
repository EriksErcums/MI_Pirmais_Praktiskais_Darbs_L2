class_name GameTree extends RefCounted

const INF: int = 1 << 30

var states: Array[State]
# Dictionary[int, Array[int]] not supported | (solution: PackedInt32Array)
var verticies: Dictionary[int, Array]

func _init(init_state: State, depth: int = -1) -> void:
	states = []
	verticies = {}
	var root_state = init_state.clone()
	states.append(root_state)
	if depth > 0:
		build_tree(0, depth)

func build_tree(state_id: int, depth: int) -> void:
	if depth == 0:
		return
	var state = states[state_id]
	state.generate_children()
	verticies[state_id] = []
	for child in state.children:
		var child_id = states.size()
		states.append(child)
		verticies[state_id].append(child_id)
		build_tree(child_id, depth - 1)


func add_state(state: State) -> void:
	states.append(state)

func add_vertice(from_id: int, to_id: int) -> void:
	if not verticies.has(from_id):
		verticies[from_id] = []
	verticies[from_id].append(to_id)
