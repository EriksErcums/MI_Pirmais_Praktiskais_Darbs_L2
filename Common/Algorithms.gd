class_name Algorithms extends Object

const MIN_INT: int = -99999
const MAX_INT: int = 99999
const PLAYER_MOVE: bool = false
const BOT_MOVE: bool = true

static func best_move(state: State, depth: int, prune: bool) -> Vector2i:
	var best_score: int = MIN_INT
	var move: Vector2i = Vector2i(-1, -1)
	print("Board:", state.nums)
	
	for i: int in state.nums.size() - 1:
		var _state: State = state.clone()
		_state.process_turn(i, i+1, BOT_MOVE)
		var score: int
		if prune: score = alphabeta(_state, depth, best_score, MAX_INT, PLAYER_MOVE)
		else: score = minimax(_state, depth, PLAYER_MOVE)
		
		print("Move ", i, "+", i+1, " -> score:", score)
		if score > best_score:
			best_score = score
			move = Vector2i(i, i+1)
	print("Chosen move:", move, " score:", best_score, "\n")
	return move

static func minimax(state: State, depth: int, is_maxing: bool) -> int:
	# Terminal state
	if state.nums.size() <= 1 || depth == 0:
		return state.eval()
	
	if is_maxing:
		var best: int = MIN_INT
		for i: int in state.nums.size()-1:
			var _state: State = state.clone()
			_state.process_turn(i, i+1, BOT_MOVE)
			var score: int = minimax(_state, depth-1, PLAYER_MOVE)
			best = max(best, score)
		return best
	else:
		var best: int = MAX_INT
		for i: int in state.nums.size()-1:
			var _state: State = state.clone()
			_state.process_turn(i, i+1, PLAYER_MOVE)
			var score: int = minimax(_state, depth-1, BOT_MOVE)
			best = min(best, score)
		return best


static func alphabeta(state: State, depth: int, alpha: int, beta: int, is_maxing: bool) -> int:
	# Terminal state
	if state.nums.size() <= 1 || depth == 0:
		return state.eval()
	
	# Player 2 (Computer) turn - maximize
	if is_maxing:
		var best: int = MIN_INT
		for i: int in state.nums.size()-1:
			var _state: State = state.clone()
			_state.process_turn(i, i+1, BOT_MOVE)
			var score: int = alphabeta(_state, depth-1, alpha, beta, PLAYER_MOVE)
			best = max(best, score)
			alpha = max(alpha, best)
			
			# pruning condition
			if beta <= alpha: break
		return best
	
	# Player 1 turn - minimize
	else:
		var best: int = MAX_INT
		for i: int in state.nums.size()-1:
			var _state: State = state.clone()
			_state.process_turn(i, i+1, PLAYER_MOVE)
			var score: int = alphabeta(_state, depth-1, alpha, beta, BOT_MOVE)
			best = min(best, score)
			beta = min(beta, best)
			
			#pruning condition
			if beta <= alpha: break
		return best
