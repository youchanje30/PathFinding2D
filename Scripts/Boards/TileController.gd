extends Node
class_name TileController

@export var tileMapLayer : TileMapLayer
@export var max_x : int = 100
@export var max_y : int = 100

# BoardData와 동일한 상수 정의
const TILE_EMPTY = 1
const TILE_WALL = -1
const TILE_PATH = 2
const TILE_START_END = 3
const TILE_ROUTE = 4

var visited_tiles : Array[Vector2i] = []
var pending_cost_cells := {}

func _ready():
	EventBus.connect("cell_changed", Callable(self, "_on_cell_changed"))
	EventBus.connect("path_finding_started", Callable(self, "_on_path_finding_started"))
	EventBus.connect("request_has_route", Callable(self, "_on_request_has_route"))
	EventBus.connect("disable_visit", Callable(self, "_on_disable_visit"))
	EventBus.connect("response_cell_cost", Callable(self, "_on_response_cell_cost"))
	for y in range(max_y):
		for x in range(max_x):
			tileMapLayer.set_cell(Vector2i(x, y), 1, Vector2i(0, 1))

func _on_cell_changed(x, y, value):
	var tile_vector := Vector2i(0, 1)
	if value == TILE_EMPTY:
		pending_cost_cells[Vector2i(x, y)] = true
		EventBus.emit_signal("request_cell_cost", x, y)
	else:
		# 기존 로직 유지
		match value:
			TILE_WALL:
				tile_vector = Vector2i(0, 0)
			TILE_PATH:
				tile_vector = Vector2i(2, 0)
				visited_tiles.push_back(Vector2i(x, y))
			TILE_ROUTE:
				tile_vector = Vector2i(3, 0)
			TILE_START_END:
				tile_vector = Vector2i(4, 0)
			_:
				tile_vector = Vector2i(1, 1)
		tileMapLayer.set_cell(Vector2i(x, y), 1, tile_vector)

func _on_path_finding_started():
	for tile in visited_tiles:
		EventBus.emit_signal("disable_visit", tile.x, tile.y)
	visited_tiles.clear()

func _on_request_has_route():
	EventBus.emit_signal("response_has_route", visited_tiles.size() > 0)

func _on_disable_visit(x, y):
	# disable_visit 신호를 받으면 해당 좌표의 방문을 해제
	# BoardData의 disable_visit과 동일한 동작을 하려면, BoardData에서 신호를 받아서 처리해야 함
	# 여기서는 단순히 타일 색상만 빈 칸으로 변경(방문 해제)
	var tile_vector := Vector2i(0, 1)
	tileMapLayer.set_cell(Vector2i(x, y), 1, tile_vector)

func _on_response_cell_cost(x, y, cost):
	var key = Vector2i(x, y)
	if key in pending_cost_cells:
		pending_cost_cells.erase(key)
		tileMapLayer.set_cell(key, 1, Vector2i(max(0, cost - 1), 1))
