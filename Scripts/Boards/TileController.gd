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
	EventBus.connect("request_has_route", Callable(self, "_on_request_has_route"))
	EventBus.connect("response_cell_cost", Callable(self, "_on_response_cell_cost"))
	EventBus.connect("clear_visited_and_route", Callable(self, "_on_clear_visited_and_route"))
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


func _on_clear_visited_and_route():
	for tile in visited_tiles:
		EventBus.emit_signal("disable_visit", tile.x, tile.y)
	visited_tiles.clear()
	EventBus.emit_signal("path_removed")

func _on_request_has_route():
	EventBus.emit_signal("response_has_route", visited_tiles.size() > 0)

func _on_response_cell_cost(x, y, cost):
	var key = Vector2i(x, y)
	if key in pending_cost_cells:
		pending_cost_cells.erase(key)
		tileMapLayer.set_cell(key, 1, Vector2i(max(0, cost - 1), 1))
