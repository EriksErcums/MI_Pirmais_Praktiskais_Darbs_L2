class_name Algorithms extends Object

const MIN_INT: int = -99999
const MAX_INT: int = 99999
const PLAYER_MOVE: bool = false
const BOT_MOVE: bool = true

static func best_move(tree: GameTree, depth: int, prune: bool) -> Vector2i:
	var best_score: int = MIN_INT
	var move: Vector2i = Vector2i(-1, -1)
	print("Board: ", tree.states[0].nums)
	
	# `i` is used only for debugging
	var i: int = 0
	for child_id: int in tree.verticies[0]:
		var score: int
		if prune: score = alphabeta(tree, child_id, depth-1, best_score, MAX_INT, BOT_MOVE)
		else: score = minimax(tree, child_id, depth-1, BOT_MOVE)
		
		print("Move ", i, "+", i+1, " -> score:", score)
		if score > best_score:
			best_score = score
			move = Vector2i(i, i+1)
		i += 1
	print("Chosen move: ", move, " score:", best_score, "\n")
	return move

static func minimax(tree: GameTree, state_id: int, depth: int, is_maxing: bool) -> int:
	var state: State = tree.states[state_id]
	# Terminal state
	if state.nums.size() <= 1 || depth == 0:
		# Trust me this one doesn't leak
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


static func alphabeta(tree: GameTree, state_id: int, depth: int, alpha: int, beta: int, is_maxing: bool) -> int:
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
			#pruning condition
			if beta <= alpha: break
		return best
