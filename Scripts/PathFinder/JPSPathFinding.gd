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
	while true:
		if pos == end: return pos
		if is_stop: return -Vector2i.ONE

		await get_tree().create_timer(0.0001).timeout 

		var next = pos + dir
		if not board.can_visit(next.x, next.y): return -Vector2i.ONE
		board.visit(next.x, next.y)
		parents[next.y][next.x] = pos

		for check_dir in move_list:
			if check_dir == dir or check_dir == -dir: continue
			var check = pos + check_dir

			if not board.is_valid_position(check.x, check.y): continue
			if not board.is_wall(check.x, check.y): continue

			var corner = check + dir
			if not board.can_visit(corner.x, corner.y): continue

			return next
	
		pos = next
	return -Vector2i.ONE
	

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
		cost = dp[pos.y][pos.x]

		for add in move_list:
			var jump_point = await jump(board_data, pos, add)
			if is_stop: return
			
			if jump_point == end: found = true; break

			if jump_point == -Vector2i.ONE: continue
			if dp[jump_point.y][jump_point.x] < heuristic(pos, jump_point) + heuristic(jump_point, end): continue

			pq.push([heuristic(pos, jump_point) + heuristic(jump_point, end), jump_point])
			dp[jump_point.y][jump_point.x] = heuristic(pos, jump_point) + heuristic(jump_point, end)
		if found: break

	print(found)
	EventBus.emit_signal("path_finding_finished", found, path(start, end, found))
