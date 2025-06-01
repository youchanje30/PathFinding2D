## 1칸에 1을 소모하는 4방향 JPS(Jump Point Search) 알고리즘
extends IPathFindingStrategy

const INF = 999999999
var dp = []
var pq = PriorityQueue.new()
var found := false
var end : Vector2i = Vector2i.ZERO
var start : Vector2i = Vector2i.ZERO

var move_list : Array[Vector2i] = [
	Vector2i(0, 1),
	Vector2i(1, 0),
	Vector2i(0, -1),
	Vector2i(-1, 0)
]

func heuristic(start : Vector2i, end : Vector2i) -> int:
	return abs(start.x - end.x) + abs(start.y - end.y)

func jump(board : BoardData, pos : Vector2i, dir : Vector2i)->Vector2i:
	await get_tree().create_timer(0.0001).timeout 
	if pos == end: return pos
	if is_stop: return -Vector2i.ONE

	var next = pos + dir
	if not board.can_visit(next.x, next.y): return -Vector2i.ONE
	board.visit(next.x, next.y)
	parents[next.y][next.x] = pos
	dp[next.y][next.x] = dp[pos.y][pos.x] + 1

	# 수평 이동일 때 (dx != 0)
	if dir.x != 0:
		if (board.can_visit(pos.x, pos.y-1) and not board.can_visit(pos.x-dir.x, pos.y-1)) or \
		 (board.can_visit(pos.x, pos.y+1) and not board.can_visit(pos.x-dir.x, pos.y+1)):
			return pos

	# 수직 이동일 때 (dy != 0)
	elif dir.y != 0:
		# 좌우로 강제 이웃이 있는지 확인
		var left_pos = Vector2i(next.x - 1, next.y)
		var right_pos = Vector2i(next.x + 1, next.y)
		var prev_left = Vector2i(next.x - 1, pos.y)
		var prev_right = Vector2i(next.x + 1, pos.y)
		
		if (board.can_visit(left_pos.x, left_pos.y) and not board.can_visit(prev_left.x, prev_left.y)) or (board.can_visit(right_pos.x, right_pos.y) and not board.can_visit(prev_right.x, prev_right.y)):
			return next
		
		# 수직 이동시 수평 방향의 점프 포인트 확인
		var left_jump = await jump(board, pos, Vector2i(-1, 0))
		if left_jump != -Vector2i.ONE: return next

		var right_jump = await jump(board, pos, Vector2i(1, 0))
		if right_jump != -Vector2i.ONE: return next
		
	return await jump(board, pos+dir, dir)

func init(max_x, max_y) -> void:
	super.init(max_x, max_y)
	set_array(dp, max_y, max_x, INF)
	pq = PriorityQueue.new()
	pq.set_comparator(comparator.less_by_first)
	found = false

func path_find(board_data : BoardData, _start : Vector2i, _end : Vector2i):
	end = _end; start = _start
	
	EventBus.emit_signal("path_finding_started")
	init(board_data.max_x, board_data.max_y)
	pq.push([heuristic(start, end), start])
	dp[start.y][start.x] = 0
	board_data.visit(start.x, start.y)

	while not pq.empty() and not found:
		var current = pq.top(); pq.pop()
		var cost = current[0]
		var pos = current[1]

		if cost - heuristic(pos, end) > dp[pos.y][pos.x]: continue
		# await get_tree().create_timer(0.0001).timeout 
		cost = dp[pos.y][pos.x]

		for add in move_list:
			var jump_point = await jump(board_data, pos, add)
			if is_stop: return

			if jump_point == end: found = true; break
			if jump_point == -Vector2i.ONE: continue

			# 누적 거리(g) 계산
			var g = dp[pos.y][pos.x] + (jump_point - pos).length()
			if dp[jump_point.y][jump_point.x] < g: continue

			dp[jump_point.y][jump_point.x] = g
			pq.push([g + heuristic(jump_point, end), jump_point])

		if found: break

	EventBus.emit_signal("path_finding_finished", found, path(start, end, found))
