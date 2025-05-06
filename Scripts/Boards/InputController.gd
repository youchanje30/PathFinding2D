extends Node

@export var board_data : Node
@export var tileMapLayer : TileMapLayer

var is_left_dragging := false
var is_right_dragging := false
var mode := 2 # 1: 시작/도착점, 2: 벽
var start_pos = null
var end_pos = null

func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1:
			mode = 1
		elif event.keycode == KEY_2:
			mode = 2
		elif event.keycode == KEY_SPACE:
			_find_path()
			return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_left_dragging = event.pressed
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			is_right_dragging = event.pressed

		if event.pressed:
			if mode == 1 and event.button_index == MOUSE_BUTTON_LEFT:
				_apply_start_end(event.position)
			elif mode == 2:
				if event.button_index == MOUSE_BUTTON_LEFT:
					_apply_wall(event.position, true)
				elif event.button_index == MOUSE_BUTTON_RIGHT:
					_apply_wall(event.position, false)

	elif event is InputEventMouseMotion and mode == 2:
		if is_left_dragging:
			_apply_wall(event.position, true)
		elif is_right_dragging:
			_apply_wall(event.position, false)

func _apply_start_end(mouse_pos):
	var global_pos = get_viewport().get_canvas_transform().affine_inverse() * mouse_pos
	var local_pos = tileMapLayer.to_local(global_pos)
	var cell = tileMapLayer.local_to_map(local_pos)
	var x = int(cell.x)
	var y = int(cell.y)
	if start_pos == null:
		start_pos = Vector2i(x, y)
		board_data.set_cell(x, y, 4) # 4: 시작점
	elif end_pos == null and Vector2i(x, y) != start_pos:
		end_pos = Vector2i(x, y)
		board_data.set_cell(x, y, 4) # 4: 도착점

func _apply_wall(mouse_pos, is_create):
	var global_pos = get_viewport().get_canvas_transform().affine_inverse() * mouse_pos
	var local_pos = tileMapLayer.to_local(global_pos)
	var cell = tileMapLayer.local_to_map(local_pos)
	var x = int(cell.x)
	var y = int(cell.y)
	if is_create:
		board_data.set_cell(x, y, 2) # 벽 생성
	else:
		board_data.set_cell(x, y, 0) # 벽 삭제

func _find_path():
	# 여기에 최단 경로 알고리즘을 구현하거나 호출하세요.
	# 예시: board_data.find_path(start_pos, end_pos)
	print("최단 경로 탐색 실행: ", start_pos, "→", end_pos)
