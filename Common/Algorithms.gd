class_name Algorithms extends Object
# \/ remove when implemented
@warning_ignore_start("unused_parameter")

static func best_move_minimax(state: State, depth: int) -> Vector2i:
	var best_score := -INF
	var _best_move := Vector2i(-1, -1)
	
	print("Board:", state.nums)
	
	for i in range(state.nums.size() - 1):
		var new_state := state.clone()
		# Player 2 makes its move
		new_state.process_turn(i, i + 1, false)
		# Player 1 responds next
		var score := minimax(new_state, depth - 1, false)
		
		var a := state.nums[i]
		var b := state.nums[i + 1]
		print("Move ", i, "+", i+1, " (", a, "+", b, ") -> score:", score)
		
		if score > best_score:
			best_score = score
			_best_move = Vector2i(i, i + 1)
	
	print("Chosen move:", _best_move, " score:", best_score)
	print("----------------------")
	return _best_move



static func minimax(state: State, depth: int, is_maxing: bool) -> int:
	# Terminal state
	if state.nums.size() <= 1 or depth == 0:
		return state.eval()
	
	# Is players 2 turn
	if is_maxing:
		var best = -INF
		for i in range(state.nums.size() - 1):
			var new_state : State = state.clone()
			new_state.process_turn(i, i + 1, false) # False = player 2 acts
			var score := minimax(new_state, depth - 1, false) # Player 1 next
			best = max(best, score)
		return best
	else:
		var best = INF
		for i in range(state.nums.size() - 1):
			var new_state : State = state.clone()
			new_state.process_turn(i, i + 1, true) # True = player 1 acts
			var score := minimax(new_state, depth - 1, true) # Player 2 next
			best = min(best, score)
		return best




static func best_move_alphabeta(state: State, depth: int) -> Vector2i:
	var best_score := -INF
	var _best_move := Vector2i(-1, -1)
	
	var alpha := -INF  
	var beta := INF   
	
	print("Board:", state.nums)
	
	for i in range(state.nums.size() - 1):
		var new_state := state.clone()
		
		# Player 2 makes its move
		new_state.process_turn(i, i + 1, false)
		
		# Player 1 responds next using alphabeta
		var score := alphabeta(new_state, depth - 1, alpha, beta, false) 
		
		var a := state.nums[i]
		var b := state.nums[i + 1]
		print("Move ", i, "+", i+1, " (", a, "+", b, ") -> score:", score)
		
		if score > best_score:
			best_score = score
			_best_move = Vector2i(i, i + 1)
		
		alpha = max(alpha, best_score) # ADDED
	
	print("Chosen move:", _best_move, " score:", best_score)
	print("----------------------")
	return _best_move




#Alpha-Beta algoritms

static func alphabeta(state: State, depth: int, alpha: int, beta: int, is_maxing: bool) -> int:
	
	# Terminal state
	if state.nums.size() <= 1 or depth == 0:
		return state.eval()
	
	# Player 2 (Computer) turn - maximize
	if is_maxing:
		var best := -INF
		
		for i in range(state.nums.size() - 1):
			var new_state : State = state.clone()
			
			new_state.process_turn(i, i + 1, false)
			
			var score := alphabeta(new_state, depth - 1, alpha, beta, false)
			
			best = max(best, score)
			alpha = max(alpha, best)
			
			# pruning condition
			if beta <= alpha:
				break
		
		return best
	
	# Player 1 turn - minimize
	else:
		var best := INF
		
		for i in range(state.nums.size() - 1):
			var new_state : State = state.clone()
			
			new_state.process_turn(i, i + 1, true)
			
			var score := alphabeta(new_state, depth - 1, alpha, beta, true)
			
			best = min(best, score)
			beta = min(beta, best)
			
			#pruning condition
			if beta <= alpha:
				break
		
		return best
