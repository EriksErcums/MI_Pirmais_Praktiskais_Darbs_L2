class_name State extends Object

var p1_score: int = 0
var p2_score: int = 0
var nums: PackedInt32Array

# Use this for simulating turns
func process_turn(pos1: int, pos2: int, p2_turn: bool) -> void:
	# Player erased last cell
	if pos1 == -1 && pos2 == -1:
		if p2_turn: p1_score -= 1
		else: p2_score -= 1
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

# Returns a score where higher is better for player 2 (AI bot)
func eval(p2_turn: bool) -> int:
	var score: int = (p2_score - p1_score) * 100
	var sevens: int = 0
	for i: int in nums.size() - 1:
		if nums[i] + nums[i+1] == 7: sevens += 1
	
	var p2_adv: bool = sevens % 2 != 0
	if !p2_turn: p2_adv = !p2_adv
	if p2_adv: score += 10
	else: score -= 10
	return score

func clone() -> State:
	var s: State = State.new()
	s.nums = nums.duplicate()
	s.p1_score = p1_score
	s.p2_score = p2_score
	return s
