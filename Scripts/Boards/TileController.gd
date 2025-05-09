extends Node

@export var tileMapLayer : TileMapLayer
@export var board_data : BoardData

@export var max_x : int = 100
@export var max_y : int = 100

var visited_tiles : Array[Vector2i] = []


func _ready():
	if board_data:
		board_data.connect("cell_changed", Callable(self, "_on_cell_changed"))
		board_data.connect("path_finding_started", Callable(self, "_on_path_finding_started"))
	for y in range(max_y):
		for x in range(max_x):
			tileMapLayer.set_cell(Vector2i(x, y), 1, Vector2i(1, 0))




func _on_cell_changed(x, y, value):
	# value에 따라 타일을 갱신하는 로직
	var tile_vector := Vector2i(0, 1) # 기본값(빈 칸)
	match value:
		board_data.TILE_WALL:
			tile_vector = Vector2i(0, 0) # 벽
		board_data.TILE_EMPTY:
			# 가중치가 1~9인 땅에 대해 색상 지정
			var cost = board_data.board[y][x][2]
			if cost >= 1 and cost <= 9:
				tile_vector = Vector2i(cost - 1, 1)
			else:
				tile_vector = Vector2i(0, 1) # 기본 빈 칸
				# tile_vector = Vector2i(1, 0) # 기본 빈 칸
		board_data.TILE_PATH:
			tile_vector = Vector2i(2, 0) # 방문
			visited_tiles.push_back(Vector2i(x, y))
		board_data.TILE_ROUTE:
			tile_vector = Vector2i(3, 0) # 최단경로
		board_data.TILE_START_END:
			tile_vector = Vector2i(4, 0) # 시작/도착점
		_:
			tile_vector = Vector2i(1, 1) # 기타(가중치 등)
	tileMapLayer.set_cell(Vector2i(x, y), 1, tile_vector)
	
func _on_path_finding_started():
	for tile in visited_tiles:
		await get_tree().create_timer(0.001).timeout
		board_data.disable_visit(tile.x, tile.y)
		print("방문 비활성화: ", tile)
	visited_tiles.clear()
