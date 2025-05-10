extends Node

@export var board_data : BoardData
@export var tileMapLayer : TileMapLayer

var is_left_dragging := false
var mode := 2 # 1: 시작/도착점, 2: 벽, 3: 가중치
var vertex_pos : Array[Vector2i] = []
var weight_value := 1

func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1:
			mode = 1
		elif event.keycode == KEY_2:
			mode = 2
		elif event.keycode == KEY_3:
			mode = 3
			weight_value = (weight_value + 1) % 9
		elif event.keycode == KEY_SPACE:
			_find_path()
			return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_left_dragging = event.pressed
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_apply_delete(event.position)

		if mode == 1 and is_left_dragging:
			_apply_start_end(event.position)

	if not is_left_dragging: return

	if mode == 2 and (event is InputEventMouseButton or event is InputEventMouseMotion):
		_apply_wall(event.position, true)

	if mode == 3 and (event is InputEventMouseButton or event is InputEventMouseMotion):
		_apply_weight(event.position)

func _apply_start_end(mouse_pos):
	if board_data.has_route():
		return # 경로가 있을 때는 시작/도착점 수정 불가
	var pos = get_position(mouse_pos)
	vertex_pos.append(pos)
	board_data.set_cell(pos.x, pos.y, board_data.TILE_START_END)

func _apply_weight(mouse_pos):
	var pos = get_position(mouse_pos)
	board_data.set_cell(pos.x, pos.y, board_data.TILE_EMPTY, weight_value) # 선택된 가중치로 땅 설치

func _apply_wall(mouse_pos, is_create):
	var pos = get_position(mouse_pos)
	board_data.set_cell(pos.x, pos.y, board_data.TILE_WALL if is_create else board_data.TILE_EMPTY)

func _apply_delete(mouse_pos):
	var pos = get_position(mouse_pos)
	board_data.set_cell(pos.x, pos.y, board_data.TILE_EMPTY)
	if pos in vertex_pos: vertex_pos.erase(pos)

func _find_path():
	if board_data.has_route():
		board_data.clear_visited_and_route()
		print("경로 및 방문 흔적만 초기화됨")
	elif vertex_pos.size() >= 2:
		print("최단 경로 탐색 실행: ", vertex_pos[0], "→", vertex_pos[1])
		board_data.try_path_find(vertex_pos[0], vertex_pos[1])
	else:
		print("경로 탐색 실행 조건 불충족")

func get_position(mouse_pos):
	var global_pos = get_viewport().get_canvas_transform().affine_inverse() * mouse_pos
	var local_pos = tileMapLayer.to_local(global_pos)
	var cell = tileMapLayer.local_to_map(local_pos)
	return Vector2i(int(cell.x), int(cell.y))
