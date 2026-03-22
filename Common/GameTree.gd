class_name GameTree extends Object

var states: Array[State]
var vertices: Dictionary[int, PackedInt32Array]

func _init(init_state: State) -> void:
	states = []
	vertices = {}
	states.append(init_state.clone())
	#if depth > 0: build_tree(0, depth, p2_turn)

func build_tree(state_id: int, depth: int, p2_turn: bool) -> void:
	if depth == 0: return
	
	var state: State = states[state_id]
	var children: Array[State] = []
	if state.nums.size() > 1:
		for i: int in state.nums.size() - 1:
			var child: State = state.clone()
			child.process_turn(i, i + 1, p2_turn)
			children.append(child)
	
	vertices[state_id] = []
	for child: State in children:
		var child_id: int = states.size()
		states.append(child)
		vertices[state_id].append(child_id)
		build_tree(child_id, depth - 1, !p2_turn)

func free_states() -> void:
	for state: State in states: state.free()
	states.clear()
	vertices.clear()
