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

func jump(board : BoardData, pos : Vector2i, dir : Vector2i, before : Vector2i):
	if not board.is_valid_position(pos.x, pos.y): return
	
	parents[pos.y][pos.x] = before
	if pos == end: found = true; return
	if is_stop: return
	board.visit(pos.x, pos.y)
	
	await get_tree().create_timer(0.001).timeout 
	for check_dir in move_list:
		if check_dir == dir or check_dir == -dir: continue
		var check = pos + check_dir
		# if check == end: parents[end.y][end.x] = pos; found = true; return
		if not board.is_valid_position(check.x, check.y): continue
		if not board.is_visited(check.x, check.y) and board.can_visit(check.x, check.y): continue
		
		var corner = check + dir
		dp[corner.y][corner.x] = heuristic(start, corner)
		pq.push([dp[corner.y][corner.x] + heuristic(corner, end), corner])
		board.visit(corner.x, corner.y)
	
	var next = pos + dir
	if not board.can_visit(next.x, next.y): return
	jump(board, pos + dir, dir, pos)

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

	while not pq.empty() and not found:
		var current = pq.top(); pq.pop()
		var cost = current[0]
		var pos = current[1]

		if cost - heuristic(pos, end) > dp[pos.y][pos.x]: continue
		cost = dp[pos.y][pos.x]

		for add in move_list:
			jump(board_data, pos + add, add, pos)
			await get_tree().create_timer(2).timeout 
			if found or is_stop: return
	print(found)
	EventBus.emit_signal("path_finding_finished", found, path(start, end, found))
