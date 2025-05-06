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
	dp.resize(0)
	for i in range(max_y):
		dp.append([])
		dp[i].resize(max_x)
		dp[i].fill(0)


func path_find(board_data : BoardData, start : Vector2i, end : Vector2i):
	init(board_data.max_x, board_data.max_y)
	var pq := PQ.new()
	pq.set_comparator(comparator.less_by_first)
	pq.push([0, start])

	var found = false

	while not pq.empty() and not found:
		var current = pq.top(); pq.pop()
		
		var pos = current[1]

		for add in move_list:
			var next_pos = pos + add
			if not board_data.can_visit(next_pos.x, next_pos.y): continue
			await get_tree().create_timer(0.001).timeout
			parents[next_pos.y][next_pos.x] = pos
			pq.push([heuristic(next_pos, end), next_pos])
			if next_pos == end: found = true; break
			board_data.visit(next_pos.x, next_pos.y)

	board_data.draw_path(path(start, end))
