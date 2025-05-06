extends Node

@export var tileMapLayer : TileMapLayer
@export var board_data : Node

@export var max_x : int = 100
@export var max_y : int = 100

func _ready():
	if board_data:
		board_data.connect("cell_changed", Callable(self, "_on_cell_changed"))
	for y in range(max_y):
		for x in range(max_x):
			tileMapLayer.set_cell(Vector2i(x, y), 0, Vector2i(0, 1))

func _on_cell_changed(x, y, value):
	# value에 따라 타일을 갱신하는 로직
	var tile_vector := Vector2i(0, 1) # 기본값(빈 칸)
	match value:
		0:
			tile_vector = Vector2i(0, 1) # 빈 칸
		1:
			tile_vector = Vector2i(1, 1) # 방문한 칸
		2:
			tile_vector = Vector2i(1, 0) # 벽
		3:
			tile_vector = Vector2i(0, 0) # 최단경로
		4:
			tile_vector = Vector2i(2, 1) # 시작 점
		_:
			tile_vector = Vector2i(0, 1) # 예외: 빈 칸
	tileMapLayer.set_cell(Vector2i(x, y), 0, tile_vector)
	print(tile_vector)
