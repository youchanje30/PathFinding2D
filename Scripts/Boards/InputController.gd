extends Node

@export var board_data : BoardData
@export var tileMapLayer : TileMapLayer

var is_left_dragging := false
var is_right_dragging := false
var mode := 2 # 1: 시작/도착점, 2: 벽, 3: 가중치
var start_pos = null
var end_pos = null
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
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			is_right_dragging = event.pressed


		if mode == 1 and is_left_dragging:
			_apply_start_end(event.position)
		

	if mode == 2 and (event is InputEventMouseButton or event is InputEventMouseMotion):
		if is_left_dragging:
			_apply_wall(event.position, true)
		elif is_right_dragging:
			_apply_wall(event.position, false)

	if mode == 3 and (event is InputEventMouseButton or event is InputEventMouseMotion):
		if is_left_dragging:
			_apply_weight(event.position)

func _apply_start_end(mouse_pos):
	var pos = get_position(mouse_pos)
	if start_pos == null:
		start_pos = pos
		board_data.set_cell(pos.x, pos.y, 3)
	elif end_pos == null and pos != start_pos:
		end_pos = pos
		board_data.set_cell(pos.x, pos.y, 3)

func _apply_weight(mouse_pos):
	var pos = get_position(mouse_pos)
	board_data.set_cell(pos.x, pos.y, weight_value, 1) # 선택된 가중치로 땅 설치

func _apply_wall(mouse_pos, is_create):
	var pos = get_position(mouse_pos)
	board_data.set_cell(pos.x, pos.y, -1 if is_create else 1)

func _find_path():
	print("최단 경로 탐색 실행: ", start_pos, "→", end_pos)
	board_data.path_find(start_pos, end_pos)

func get_position(mouse_pos):
	var global_pos = get_viewport().get_canvas_transform().affine_inverse() * mouse_pos
	var local_pos = tileMapLayer.to_local(global_pos)
	var cell = tileMapLayer.local_to_map(local_pos)
	return Vector2i(int(cell.x), int(cell.y))
