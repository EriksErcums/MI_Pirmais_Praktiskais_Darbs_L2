class_name State extends RefCounted

var nums: PackedInt32Array
var p1_score: int = 0
var p2_score: int = 0

# Use this for simulating turns
func process_turn(pos1: int, pos2: int, p2_turn: bool) -> void:
	# Player erased last cell
	if pos1 == -1 && pos2 == -1:
		if p2_turn: p2_score -= 1
		else: p1_score -= 1
		nums.clear()
		return
	
	# Player merged 2 cells into 1
	var sum: int = nums[pos1] + nums[pos2]
	var score: int = 2 if sum == 7 else 1
	
	if sum > 6: nums[pos1] = sum - 6
	else: nums[pos1] = sum
	nums.remove_at(pos2)
	
	if p2_turn: p2_score += score
	else: p1_score += score

# Returns a score where higher is better for player 2(AI bot)
func eval() -> int:
	var score: int = (p2_score - p1_score) * 100
	for i: int in nums.size() - 1:
		var sum: int = nums[i] + nums[i+1]
		
		if sum == 7: score += 45
		elif sum == 6 || sum == 8: score += 8
		elif sum == 5 || sum == 9: score += 3
		
		if sum > 6: sum -= 6
		if sum == 3 || sum == 4: score += 2
	return score

func clone() -> State:
	var s: State = State.new()
	s.nums = nums.duplicate()
	s.p1_score = p1_score
	s.p2_score = p2_score
	return s
