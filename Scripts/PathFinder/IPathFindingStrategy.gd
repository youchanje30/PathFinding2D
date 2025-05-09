## 경로 탐색 전략 인터페이스
extends Node
class_name IPathFindingStrategy

var parents = []


#region Utility
func set_array(arr : Array, r : int, size : int, val):
	arr.resize(0)
	for i in range(r):
		arr.append([])
		arr[i].resize(size)
		arr[i].fill(val)
#endregion

func init(max_x : int, max_y : int):
	set_array(parents, max_y, max_x, Vector2i(-1, -1))

func path_find(board_data : BoardData, start : Vector2i, end : Vector2i):
	init(board_data.max_x, board_data.max_y)
	board_data.draw_path(path(start, end))


func path(start : Vector2i, end : Vector2i) -> Array[Vector2i]:
	var paths : Array[Vector2i] = []
	var parent : Vector2i = parents[end.y][end.x]
	while parent != start:
		paths.append(parent)
		parent = parents[parent.y][parent.x]
	return paths
