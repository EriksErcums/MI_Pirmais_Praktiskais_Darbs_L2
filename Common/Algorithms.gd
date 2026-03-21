class_name Algorithms extends RefCounted

const MIN_INT: int = -99999
const MAX_INT: int = 99999
const PLAYER_MOVE: bool = false
const BOT_MOVE: bool = true

var time_per_cell: PackedInt32Array
var time_total: int
var time_avg: float
var iterations: int

func best_move(tree: GameTree, depth: int, prune: bool) -> Vector2i:
	var best_score: int = MIN_INT
	var move: Vector2i = Vector2i(-1, -1)
	
	time_per_cell.clear()
	time_total = 0
	iterations = 0
	print("Board: ", tree.states[0].nums)
	var i: int = 0 # `i` is used only for printing
	for child_id: int in tree.verticies[0]:
		var start_usec: int = Time.get_ticks_usec()
		
		var score: int
		if prune: score = alphabeta(tree, child_id, depth-1, best_score, MAX_INT, BOT_MOVE)
		else: score = minimax(tree, child_id, depth-1, BOT_MOVE)
		if score > best_score:
			best_score = score
			move = Vector2i(i, i+1)
		
		print("Move ", i, "+", i+1, " -> score:", score)
		i += 1
		var diff: int = Time.get_ticks_usec() - start_usec
		time_per_cell.append(diff)
		time_total += diff
	print("Chosen move: ", move, " score:", best_score, "\n")
	time_avg = snapped(time_total * 1.0/time_per_cell.size(), 0.01)
	return move

func minimax(tree: GameTree, state_id: int, depth: int, is_maxing: bool) -> int:
	iterations += 1
	var state: State = tree.states[state_id]
	# Terminal state
	if state.nums.size() <= 1 || depth == 0:
		return state.eval(is_maxing)
	
	if is_maxing:
		var best: int = MIN_INT
		for child_id: int in tree.verticies[state_id]:
			var score: int = minimax(tree, child_id, depth-1, PLAYER_MOVE)
			best = max(best, score)
		return best
	else:
		var best: int = MAX_INT
		for child_id: int in tree.verticies[state_id]:
			var score: int = minimax(tree, child_id, depth-1, BOT_MOVE)
			best = min(best, score)
		return best


func alphabeta(tree: GameTree, state_id: int, depth: int, alpha: int, beta: int, is_maxing: bool) -> int:
	iterations += 1
	var state: State = tree.states[state_id]
	# Terminal state
	if state.nums.size() <= 1 || depth == 0:
		return state.eval(is_maxing)
	
	# Player 2 (Computer) turn - maximize
	if is_maxing:
		var best: int = MIN_INT
		for child_id: int in tree.verticies[state_id]:
			var score: int = alphabeta(tree, child_id, depth-1, alpha, beta, PLAYER_MOVE)
			best = max(best, score)
			alpha = max(alpha, best)
			# pruning condition
			if beta <= alpha: break
		return best
	
	# Player 1 turn - minimize
	else:
		var best: int = MAX_INT
		for child_id: int in tree.verticies[state_id]:
			var score: int = alphabeta(tree, child_id, depth-1, alpha, beta, BOT_MOVE)
			best = min(best, score)
			beta = min(beta, best)
			# pruning condition
			if beta <= alpha: break
		return best
