extends Node

@export var tileMapLayer : TileMapLayer
@export var board_data : BoardData

@export var max_x : int = 100
@export var max_y : int = 100

func _ready():
	if board_data:
		board_data.connect("cell_changed", Callable(self, "_on_cell_changed"))
	for y in range(max_y):
		for x in range(max_x):
			tileMapLayer.set_cell(Vector2i(x, y), 1, Vector2i(1, 0))

func _on_cell_changed(x, y, value):
	# value에 따라 타일을 갱신하는 로직
	var tile_vector := Vector2i(0, 1) # 기본값(빈 칸)
	match value:
		-1:
			tile_vector = Vector2i(0, 0) # 벽
		0:
			tile_vector = Vector2i(1, 0) # 빈 칸
		1:
			tile_vector = Vector2i(2, 0) # 방문한 칸
		2:
			tile_vector = Vector2i(3, 0) # 최단경로
		3:
			tile_vector = Vector2i(4, 0) # 시작 점
		_:
			tile_vector = Vector2i(value - 4, 1) 
	tileMapLayer.set_cell(Vector2i(x, y), 1, tile_vector)
	
