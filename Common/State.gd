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
	
	if turn: p1_score += score
	else: p2_score += score

# Returns a score where higher is better for player 2(AI bot)
func eval() -> int:
	var score := (p2_score - p1_score) * 100
	
	for i in range(nums.size() - 1):
		var sum := nums[i] + nums[i + 1]
		
		if sum == 7:
			score += 25
		elif sum == 6 or sum == 8:
			score += 8
		elif sum == 5 or sum == 9:
			score += 3
		
		var result := sum
		if result > 6:
			result -= 6
		
		if result == 3 or result == 4:
			score += 2
	
	var sevens := 0
	for i in range(nums.size() - 1):
		if nums[i] + nums[i+1] == 7:
			sevens += 1
	score += sevens * 20
	
	score += (15 - nums.size())
	return score

func clone() -> State:
	var s := State.new()
	s.nums = nums.duplicate()
	s.p1_score = p1_score
	s.p2_score = p2_score
	return s
