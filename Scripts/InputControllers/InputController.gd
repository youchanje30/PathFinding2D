extends Node
class_name InputController
# BoardData와 동일한 상수 정의
const TILE_EMPTY = 1
const TILE_WALL = -1
const TILE_PATH = 2
const TILE_START_END = 3
const TILE_ROUTE = 4

@export var tileMapLayer : TileMapLayer
@export var state_controller : StateController

var is_left_dragging := false
var mode := 2 # 1: 시작/도착점, 2: 벽, 3: 가중치
var vertex_pos : Array[Vector2i] = []
var weight_value := 1
var can_fix := true # 수정 가능 여부

# 경로 존재 여부 질의/응답 비동기 처리용
var pending_path_find := false

func _ready():
	EventBus.connect("path_finding_started", Callable(self, "_on_path_finding_started"))
	EventBus.connect("path_removed", Callable(self, "_on_path_removed"))

func _unhandled_input(event):
	# 입력 이벤트를 StateController에 위임
	if state_controller:
		state_controller.handle_input(event)
		
	if not can_fix: return
	if event is InputEventKey and event.pressed: _handle_key_input(event)

func _handle_key_input(event):
	match event.keycode:
		KEY_1:
			mode = 1
		KEY_2:
			mode = 2
		KEY_3:
			mode = 3
			weight_value = (weight_value + 1) % 9
		#KEY_SPACE:
			#_find_path()

func _apply_start_end(mouse_pos):
	var pos = get_position(mouse_pos)
	if pos in vertex_pos: return
	vertex_pos.append(pos)
	EventBus.emit_signal("set_cell", pos.x, pos.y, TILE_START_END, 0)

func _apply_weight(mouse_pos):
	var pos = get_position(mouse_pos)
	if pos in vertex_pos: _apply_delete(mouse_pos)
	EventBus.emit_signal("set_cell", pos.x, pos.y, TILE_EMPTY, weight_value) # 선택된 가중치로 땅 설치

func _apply_wall(mouse_pos, is_create):
	var pos = get_position(mouse_pos)
	if is_create and pos in vertex_pos: _apply_delete(mouse_pos)
	EventBus.emit_signal("set_cell", pos.x, pos.y, TILE_WALL if is_create else TILE_EMPTY, 0)

func _apply_delete(mouse_pos):
	var pos = get_position(mouse_pos)
	EventBus.emit_signal("set_cell", pos.x, pos.y, TILE_EMPTY, 1)
	while pos in vertex_pos: vertex_pos.erase(pos)

func _find_path():
	if can_fix:
		if vertex_pos.size() >= 2:
			print("최단 경로 탐색 실행: ", vertex_pos[0], "→", vertex_pos[1])
			can_fix = false
			EventBus.emit_signal("try_path_find", vertex_pos[0], vertex_pos[1])
		else:
			print("경로 탐색 실행 조건 불충족")
	else:
		EventBus.emit_signal("clear_visited_and_route")
		print("경로 및 방문 흔적만 초기화됨")

func get_position(mouse_pos):
	var global_pos = get_viewport().get_canvas_transform().affine_inverse() * mouse_pos
	var local_pos = tileMapLayer.to_local(global_pos)
	var cell = tileMapLayer.local_to_map(local_pos)
	return Vector2i(int(cell.x), int(cell.y))

func _on_path_finding_started():
	can_fix = false

func _on_path_removed():
	can_fix = true
