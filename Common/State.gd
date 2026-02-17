class_name State extends RefCounted

var nums: PackedInt32Array
var p1_score: int = 0
var p2_score: int = 0

# Use this for simulating turns
func process_turn(pos1: int, pos2: int, turn: bool) -> void:
	# Player erased last cell
	if pos1 == -1 && pos2 == -1:
		if turn: p1_score -= 1
		else: p2_score -= 1
		nums.clear()
		return
	
	# Player merged 2 cells into 1
	var sum: int = nums[pos1] + nums[pos2]
	var score: int = 2 if sum == 7 else 1
	
	if sum > 6: nums[pos1] = sum - 6
	else: nums[pos1] = sum
	nums.remove_at(pos2)
	
	if turn: p2_score += score
	else: p1_score += score
