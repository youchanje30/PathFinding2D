extends Node
class_name BoardData

## 판의 최대 가로 크기
@export var max_x : int = 100
## 판의 최대 세로 크기
@export var max_y : int = 100

## 경로 탐색 전략
@export var path_finding_strategy : IPathFindingStrategy

var board : Array[Array] = []

signal cell_changed(x, y, value)
signal path_finding_started()

func _ready():
	init_board(max_x, max_y)


## 판을 생성 합니다.
func init_board(_max_x : int, _max_y : int):
	max_x = _max_x
	max_y = _max_y
	board.resize(max_y)
	for i in range(max_y):
		board[i].resize(max_x)
	reset_board()


## 판을 초기화 합니다
func reset_board():
	for i in range(max_y):
		for j in range(max_x):
			board[i][j] = [false, 1] # 기본 땅은 1

## 유효한 위치 인지 확인합니다.
## 유효할 경우 true, 유효하지 않을 경우 false를 반환합니다.
func is_valid_position(x : int, y : int) -> bool:
	return x >= 0 and x < max_x and y >= 0 and y < max_y

## 방문한 위치 인지 확인합니다.
## 방문한 경우 true, 방문하지 않은 경우 false를 반환합니다.
func is_visited(x : int, y : int) -> bool:
	return board[y][x][0]

## 셀의 값을 변경하고, 변경 신호를 발생시킵니다.
func set_cell(x: int, y: int, value, type : int = 0):
	if not is_valid_position(x, y): return
	# 벽은 -1, 나머지는 최소 1
	board[y][x][1] = value
	emit_signal("cell_changed", x, y, type * 4 + value)



#region Path Finding Methods
func can_visit(x : int, y : int) -> bool:
	return is_valid_position(x, y) and not is_visited(x, y) and board[y][x][1] != -1

func visit(x : int, y : int):
	board[y][x][0] = true
	emit_signal("cell_changed", x, y, 1)

func disable_visit(x : int, y : int):
	board[y][x][0] = false
	print(x, y)
	emit_signal("cell_changed", x, y, 0)

func get_cost(x : int, y : int) -> int:
	var v = board[y][x][1]
	return v if v > 0 else 1

func path_find(start : Vector2, end : Vector2):
	board[start.y][start.x][0] = true
	path_finding_strategy.path_find(self, start, end)

func draw_path(path : Array[Vector2i]):
	for cell in path:
		emit_signal("cell_changed", cell[0], cell[1], 2)

func try_path_find(start : Vector2, end : Vector2):
	emit_signal("path_finding_started")
	await get_tree().create_timer(0.25).timeout
	path_find(start, end)
#endregion
