## 1칸에 1을 소모하는 4방향 JPS(Jump Point Search) 알고리즘
extends IPathFindingStrategy

const NVec = -Vector2i.ONE
const INF = 999999999
var dp = []
var closed = []
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

func jump(board : BoardData, x:int, y:int, px:int, py:int)->Vector2i:
	#await get_tree().create_timer(0.0001).timeout 
	
	var dx = x - px
	var dy = y - py
	
	if not board.wakable(x, y): return NVec
	if Vector2i(x, y) == end: return Vector2i(x, y)
	# board.visit(x, y)
	
	if dx != 0:
		if (board.wakable(x, y-1) and not board.wakable(x - dx, y-1)) or\
		(board.wakable(x, y+1) and not board.wakable(x - dx, y+1)):
			return Vector2i(x, y)
	elif dy != 0:
		if (board.wakable(x-1, y) and not board.wakable(x - 1, y-dy)) or\
		(board.wakable(x+1, y) and not board.wakable(x + 1, y-dy)):
			return Vector2i(x, y)
		
		if await jump(board, x+1, y, x, y) != NVec or await jump(board, x-1, y, x, y) != NVec:
			return Vector2i(x, y)
	else:
		print("Error")
	
	return await jump(board, x + dx, y + dy, x, y)

func findNeighbors(board : BoardData, x : int, y : int)->Array[Vector2i]:
	var parent = parents[y][x]
	var px = parent.x
	var py = parent.y
	
	var neighbors : Array[Vector2i] = []
	if parent == NVec:
		for move in move_list:
			var pos = move + Vector2i(x, y)
			#if not board.wakable(pos.x, pos.y): continue
			neighbors.append(move + Vector2i(x, y))
		return neighbors
	var dx : int = (x - px) / max(abs(x-px), 1)
	var dy : int = (y - py) / max(abs(y-py), 1)
	if dx != 0:
		if board.wakable(x, y-1): neighbors.append(Vector2i(x, y-1))
		if board.wakable(x, y+1): neighbors.append(Vector2i(x, y+1))
		if board.wakable(x + dx, y): neighbors.append(Vector2i(x + dx, y))
	else:
		if board.wakable(x-1, y): neighbors.append(Vector2i(x-1, y))
		if board.wakable(x+1, y): neighbors.append(Vector2i(x+1, y))
		if board.wakable(x, y + dy): neighbors.append(Vector2i(x, y + dy))
	return neighbors

func init(max_x, max_y) -> void:
	super.init(max_x, max_y)
	set_array(dp, max_y, max_x, INF)
	set_array(closed, max_y, max_x, false)
	
	pq = PriorityQueue.new()
	pq.set_comparator(comparator.less_by_first)
	found = false

func path_find(board_data : BoardData, _start : Vector2i, _end : Vector2i, is_delay : bool = false):
	EventBus.emit_signal("path_finding_started")
	init(board_data.max_x, board_data.max_y)
	
	end = _end; start = _start
	dp[start.y][start.x] = 0
	pq.push([heuristic(start, end), start])

	while not pq.empty() and not found:
		var current = pq.top(); pq.pop();
		
		var pos = current[1]
		if pos == end: found = true; break
		if current[0] - heuristic(pos, end) > dp[pos.y][pos.x]: continue
		if closed[pos.y][pos.x]: continue
		closed[pos.y][pos.x] = true
		
		var g = current[0] - heuristic(end, pos)
		board_data.visit(pos.x, pos.y)
		
		var neighbors = findNeighbors(board_data, pos.x, pos.y)
		
		for neighbor in neighbors:
			var nx = neighbor.x
			var ny = neighbor.y
			
			var jumpPoint = await jump(board_data, nx, ny, pos.x, pos.y)


			if is_delay: await get_tree().create_timer(0.05).timeout 
			if jumpPoint == NVec: continue
			
			var d = heuristic(jumpPoint, pos)
			var ng = g + d
			if ng > dp[jumpPoint.y][jumpPoint.x]: continue
			
			dp[jumpPoint.y][jumpPoint.x] = ng
			parents[jumpPoint.y][jumpPoint.x] = pos
			var f = ng + heuristic(jumpPoint, end)
			pq.push([f, jumpPoint])
	
	if found: SetPath(board_data)
	EventBus.emit_signal("path_finding_finished", found, path(start, end, found))


func SetPath(board : BoardData):
	var cur : Vector2i = end
	var target : Vector2i
	while cur != start:
		target = parents[cur.y][cur.x]
		var dir = target - cur
		dir.x = clampi(dir.x, -1, 1)
		dir.y = clampi(dir.y, -1, 1)
		while cur != target:
			board.visit(cur.x, cur.y)
			var next = cur + dir
			parents[cur.y][cur.x] = next
			cur = next
	
	
