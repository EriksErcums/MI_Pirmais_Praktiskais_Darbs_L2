class_name State extends RefCounted

var nums: PackedInt32Array
var p1_score: int = 0
var p2_score: int = 0

# Use this for simulating turns
func process_turn(_state: State, pos1: int, pos2: int, _turn: bool) -> void:
	# Player erased last cell
	if pos1 == -1 && pos2 == -1:
		if _turn: _state.p1_score -= 1
		else: _state.p2_score -= 1
		_state.nums.clear()
		return
	
	# Player merged 2 cells into 1
	var sum: int = _state.nums[pos1] + _state.nums[pos2]
	var score: int = 2 if sum == 7 else 1
	
	if sum > 6: _state.nums[pos1] = sum - 6
	else: _state.nums[pos1] = sum
	_state.nums.remove_at(pos2)
	
	if _turn: _state.p2_score += score
	else: _state.p1_score += score
