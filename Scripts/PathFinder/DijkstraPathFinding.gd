## 1칸에 1을 소모하는 Dijkstra 최단경로 탐색 알고리즘
extends IPathFindingStrategy

var dp = []


var move_list : Array[Vector2i] = [
	Vector2i(0, 1),
	Vector2i(1, 0),
	Vector2i(0, -1),
	Vector2i(-1, 0)
]

func init(max_x, max_y) -> void:
	super.init(max_x, max_y)
	set_array(dp, max_y, max_x, 999999999)


func path_find(board_data : BoardData, start : Vector2i, end : Vector2i):
	init(board_data.max_x, board_data.max_y)
	var pq := PQ.new()
	pq.set_comparator(comparator.less_by_first)
	pq.push([0, start])
	dp[start.y][start.x] = 0

	var found = false

	while not pq.empty() and not found:
		var current = pq.top(); pq.pop()

		var cost = current[0]
		var pos = current[1]
		
		if cost > dp[pos.y][pos.x]: continue
		
		for add in move_list:
			var next_pos = pos + add
			var next_cost = cost + 1
			if not board_data.can_visit(next_pos.x, next_pos.y): continue
			if next_cost >= dp[next_pos.y][next_pos.x]: continue
			await get_tree().create_timer(0.001).timeout

			dp[next_pos.y][next_pos.x] = next_cost
			pq.push([next_cost, next_pos])
			parents[next_pos.y][next_pos.x] = pos
			if next_pos == end: found = true; break
			board_data.visit(next_pos.x, next_pos.y)

	board_data.draw_path(path(start, end))
