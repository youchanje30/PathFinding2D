## 1칸에 1을 소모하는 A* 최단경로 탐색 알고리즘
extends IPathFindingStrategy

var dp = []


var move_list : Array[Vector2i] = [
	Vector2i(0, 1),
	Vector2i(1, 0),
	Vector2i(0, -1),
	Vector2i(-1, 0)
]

func heuristic(start : Vector2i, end : Vector2i) -> int:
	return abs(start.x - end.x) + abs(start.y - end.y)

func init(max_x, max_y) -> void:
	super.init(max_x, max_y)
	set_array(dp, max_y, max_x, 999999999)


func path_find(board_data : BoardData, start : Vector2i, end : Vector2i):
	init(board_data.max_x, board_data.max_y)
	var pq := PQ.new()
	pq.set_comparator(comparator.less_by_first)
	pq.push([heuristic(start, end), start])
	dp[start.y][start.x] = 0

	var found = false

	while not pq.empty() and not found:
		var current = pq.top(); pq.pop()
		var cost = current[0]
		var pos = current[1]

		if cost - heuristic(pos, end) > dp[pos.y][pos.x]: continue
		cost = dp[pos.y][pos.x]

		for add in move_list:
			var next_pos = pos + add
			if not board_data.can_visit(next_pos.x, next_pos.y): continue
			var cell_weight = board_data.get_cost(next_pos.x, next_pos.y)
			if cost + cell_weight >= dp[next_pos.y][next_pos.x]: continue
			await get_tree().create_timer(0.001).timeout
			dp[next_pos.y][next_pos.x] = cost + cell_weight
			parents[next_pos.y][next_pos.x] = pos
			pq.push([dp[next_pos.y][next_pos.x] + heuristic(next_pos, end), next_pos])
			if next_pos == end: found = true; break
			board_data.visit(next_pos.x, next_pos.y)

	board_data.draw_path(path(start, end))
