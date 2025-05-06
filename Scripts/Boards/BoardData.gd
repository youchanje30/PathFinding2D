extends Node


## 판의 최대 가로 크기
@export var max_x : int = 100
## 판의 최대 세로 크기
@export var max_y : int = 100

var board : Array[Array] = []

signal cell_changed(x, y, value)


func _ready(): init_board(max_x, max_y)


## 판을 생성 합니다.
func init_board(_max_x : int, _max_y : int):
	max_x = _max_x
	max_y = _max_y
	board.resize(max_y)
	for i in range(max_y): board[i].resize(max_x)
	reset_board()


## 판을 초기화 합니다
func reset_board():
	for i in range(max_y):
		for j in range(max_x):
			board[i][j] = false

## 유효한 위치 인지 확인합니다.
## 유효할 경우 true, 유효하지 않을 경우 false를 반환합니다.
func is_valid_position(x : int, y : int) -> bool:
	return x >= 0 and x < max_x and y >= 0 and y < max_y

## 방문한 위치 인지 확인합니다.
## 방문한 경우 true, 방문하지 않은 경우 false를 반환합니다.
func is_visited(x : int, y : int) -> bool:
	return board[x][y]

## 셀의 값을 변경하고, 변경 신호를 발생시킵니다.
func set_cell(x: int, y: int, value):
	if is_valid_position(x, y):
		board[y][x] = value
		emit_signal("cell_changed", x, y, value)
