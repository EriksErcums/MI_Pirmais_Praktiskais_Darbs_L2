class_name GameTree extends RefCounted

var states: Array[State]
var verticies: Dictionary[int, int]

# \/ remove when implemented
@warning_ignore_start("unused_parameter")
func _init(init_state: State, depth: int = -1) -> void:
	pass

func add_state(state: State) -> void:
	states.append(state)

func add_vertice(from_id: int, to_id: int) -> void:
	verticies[from_id] = to_id
