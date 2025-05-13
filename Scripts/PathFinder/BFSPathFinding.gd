## 1칸에 1을 소모하는 BFS 최단경로 탐색 알고리즘
extends IPathFindingStrategy

var move_list : Array[Vector2i] = [
	Vector2i(0, 1),
	Vector2i(1, 0),
	Vector2i(0, -1),
	Vector2i(-1, 0)
]

func path_find(board_data : BoardData, start : Vector2i, end : Vector2i):
	EventBus.emit_signal("path_finding_started")
	init(board_data.max_x, board_data.max_y)
	var queue : Array = [start]
	parents[start.y][start.x] = start
	var found = false

	while not queue.is_empty() and not found:
		var current : Vector2i = queue.pop_front()
		for move in move_list:
			var next = current + move
			if not board_data.can_visit(next.x, next.y): continue

			await get_tree().create_timer(0.001).timeout

			queue.append(next)
			parents[next.y][next.x] = current

			if next == end: found = true; break
			if is_stop: return
			board_data.visit(next.x, next.y)

	EventBus.emit_signal("path_finding_finished", found, path(start, end))
