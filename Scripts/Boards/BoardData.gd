extends Node
class_name BoardData

# BoardData와 동일한 상수 정의
const TILE_EMPTY = 1
const TILE_WALL = -1
const TILE_PATH = 2
const TILE_START_END = 3
const TILE_ROUTE = 4


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
	EventBus.connect("set_cell", Callable(self, "_on_set_cell"))
	EventBus.connect("remove_cell", Callable(self, "_on_remove_cell"))
	EventBus.connect("try_path_find", Callable(self, "_on_try_path_find"))
	EventBus.connect("clear_visited_and_route", Callable(self, "_on_clear_visited_and_route"))
	EventBus.connect("path_finding_strategy_changed", Callable(self, "_on_path_finding_strategy_changed"))
	EventBus.connect("request_cell_cost", Callable(self, "_on_request_cell_cost"))
	EventBus.connect("disable_visit", Callable(self, "_on_disable_visit"))
	EventBus.connect("path_finding_finished", Callable(self, "_on_path_finding_finished"))
	

func _on_set_cell(x, y, value, cost):
	set_cell(x, y, value, cost)

func _on_remove_cell(x, y):
	remove_cell(x, y)

func _on_try_path_find(start, end):
	path_find(start, end)

func _on_path_finding_strategy_changed(strategy):
	change_path_find_strategy(strategy)

func _on_request_cell_cost(x, y):
	if is_valid_position(x, y):
		EventBus.emit_signal("response_cell_cost", x, y, get_cost(x, y))

func _on_disable_visit(x, y):
	disable_visit(x, y)

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
			board[i][j] = [false, TILE_EMPTY, 1] # 방문X, 빈 땅, 가중치 1

## 유효한 위치 인지 확인합니다.
## 유효할 경우 true, 유효하지 않을 경우 false를 반환합니다.
func is_valid_position(x : int, y : int) -> bool:
	return x >= 0 and x < max_x and y >= 0 and y < max_y

func _on_clear_visited_and_route():
	if not path_finding_strategy: return
	path_finding_strategy.stop_path_find()

## 방문한 위치 인지 확인합니다.
## 방문한 경우 true, 방문하지 않은 경우 false를 반환합니다.
func is_visited(x : int, y : int) -> bool:
	return board[y][x][0]

## 셀의 상태와 가중치를 변경하고, 변경 신호를 발생시킵니다.
func set_cell(x: int, y: int, state: int, cost: int = 1):
	if not is_valid_position(x, y): return
	board[y][x][1] = state
	board[y][x][2] = cost
	EventBus.emit_signal("cell_changed", x, y, state)

func remove_cell(x: int, y: int):
	if not is_valid_position(x, y): return
	board[y][x][0] = false
	set_cell(x, y, TILE_EMPTY)
	EventBus.emit_signal("cell_removed", x, y)

func is_wall(x:int, y:int)->bool:
	return board[y][x][1] == TILE_WALL

## 셀의 가중치만 변경
func set_cost(x: int, y: int, cost: int):
	if not is_valid_position(x, y): return
	board[y][x][2] = cost
	EventBus.emit_signal("cell_cost_changed", x, y, cost)

#region Path Finding Methods
func can_visit(x : int, y : int) -> bool:
	return is_valid_position(x, y) and not is_visited(x, y) and board[y][x][1] != TILE_WALL

func visit(x : int, y : int):
	board[y][x][0] = true
	EventBus.emit_signal("cell_changed", x, y, TILE_PATH)

func disable_visit(x : int, y : int):
	board[y][x][0] = false
	EventBus.emit_signal("cell_changed", x, y, TILE_EMPTY if board[y][x][1] != TILE_START_END else TILE_START_END)

func get_cost(x : int, y : int) -> int:
	return board[y][x][2]

func path_find(start : Vector2, end : Vector2):
	board[start.y][start.x][0] = true
	path_finding_strategy.enable_path_find()
	path_finding_strategy.path_find(self, start, end)

func change_path_find_strategy(strategy : IPathFindingStrategy):
	path_finding_strategy = strategy

func draw_path(path : Array[Vector2i]):
	for cell in path:
		EventBus.emit_signal("cell_changed", cell[0], cell[1], TILE_ROUTE)
	EventBus.emit_signal("path_drawn", path)

func _on_path_finding_finished(success : bool, path : Array[Vector2i]):
	if success: draw_path(path)
#endregion
