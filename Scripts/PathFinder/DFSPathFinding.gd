## 1칸에 1을 소모하는 DFS 탐색 알고리즘
## 최단 경로를 보장하기 위해서는 모든 방법을 확인해야 한다.
## 즉, 최단 경로로는 부적합하다. 이를 위한 예시이다.
extends IPathFindingStrategy

var move_list : Array[Vector2i] = [
	Vector2i(0, 1),
	Vector2i(1, 0),
	Vector2i(0, -1),
	Vector2i(-1, 0)
]

func path_find(board_data : BoardData, start : Vector2i, end : Vector2i, is_delay : bool = false):
	EventBus.emit_signal("path_finding_started")
	init(board_data.max_x, board_data.max_y)
	var queue : Array = [start]
	parents[start.y][start.x] = start
	var found = false

	while not queue.is_empty() and not found:
		var current : Vector2i = queue.pop_back()
		for move in move_list:
			var next = current + move
			if not board_data.can_visit(next.x, next.y): continue

			if is_delay: await get_tree().create_timer(0.001).timeout

			queue.append(next)
			parents[next.y][next.x] = current

			if next == end: found = true; break
			if is_stop: return

			board_data.visit(next.x, next.y)

	EventBus.emit_signal("path_finding_finished", found, path(start, end, found))
