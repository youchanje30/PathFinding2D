class_name PathFindingTest
extends Node

const MAP_SIZE = 100
const WALL_PERCENTAGE = 30  # 30% of the map will be walls
const TOTAL_TESTS = 100

@export var path_finding_manager : PathFindingManager
@export var board_data : BoardData

var start_pos: Vector2i
var end_pos: Vector2i
var current_test_index := 0
var algorithm_names := ["BFS", "A*", "JPS", "Dijkstra"]
var path_lengths := {}
var test_count := 1

# 통계 데이터
var diff_counts := {
	"A*": {"same": 0, "different": 0, "total_diff": 0},
	"JPS": {"same": 0, "different": 0, "total_diff": 0},
	"Dijkstra": {"same": 0, "different": 0, "total_diff": 0}
}

func _ready():
	start_new_test()

func _input(event):
	if event.is_action_pressed("ui_accept"):  # 스페이스 키
		reset_statistics()
		for i in range(TOTAL_TESTS):
			start_new_test()
			await test_completed
		print_statistics()

signal test_completed

func reset_statistics():
	test_count = 1
	for algo in diff_counts.keys():
		diff_counts[algo] = {"same": 0, "different": 0, "total_diff": 0}

func start_new_test():
	if test_count <= TOTAL_TESTS:
		print("\n=== Test #", test_count, " ===")
		current_test_index = 0
		path_lengths.clear()
		
		# 맵 초기화
		clear_map()
		initialize_test()
		run_test()
		test_count += 1

func clear_map():
	# 모든 셀을 빈 셀로 초기화
	for y in range(MAP_SIZE):
		for x in range(MAP_SIZE):
			board_data.set_cell(x, y, BoardData.TILE_EMPTY)
	# 방문 정보와 경로 초기화
	EventBus.emit_signal("clear_visited_and_route")

func initialize_test():
	generate_test_points()
	generate_random_walls()
	
	# Connect to signals
	if not EventBus.is_connected("path_finding_finished", _on_path_finding_finished):
		EventBus.connect("path_finding_finished", _on_path_finding_finished)
	if not EventBus.is_connected("path_drawn", _on_path_drawn):
		EventBus.connect("path_drawn", _on_path_drawn)
	
func generate_test_points():
	# 시작점과 도착점을 맵의 반대편에 위치시키기
	start_pos = Vector2i(10, 10)
	end_pos = Vector2i(MAP_SIZE - 10, MAP_SIZE - 10)
	
	# 시작점과 도착점을 보드에 표시
	board_data.set_cell(start_pos.x, start_pos.y, BoardData.TILE_START_END)
	board_data.set_cell(end_pos.x, end_pos.y, BoardData.TILE_START_END)

func generate_random_walls():
	var total_cells = MAP_SIZE * MAP_SIZE
	var wall_count = (total_cells * WALL_PERCENTAGE) / 100
	
	for i in range(wall_count):
		var x = randi() % MAP_SIZE
		var y = randi() % MAP_SIZE
		# 시작점과 도착점에는 벽을 생성하지 않음
		if Vector2i(x, y) != start_pos and Vector2i(x, y) != end_pos:
			board_data.set_cell(x, y, BoardData.TILE_WALL)

func run_test():
	test_next_algorithm()

func test_next_algorithm():
	if current_test_index >= algorithm_names.size():
		print_results()
		compare_with_bfs()
		emit_signal("test_completed")
		return
		
	path_finding_manager._on_select_path_finding_item_selected(current_test_index)
	board_data.path_find(Vector2(start_pos.x, start_pos.y), Vector2(end_pos.x, end_pos.y))

func print_results():
	var result = "Results: "
	for algo in algorithm_names:
		result += algo + ": " + str(path_lengths.get(algo, "No path")) + " | "
	print(result.trim_suffix(" | "))

func compare_with_bfs():
	var bfs_length = path_lengths.get("BFS")
	if typeof(bfs_length) == TYPE_STRING: return  # "No path"인 경우
		
	for algo in algorithm_names.slice(1):  # BFS 제외한 나머지 알고리즘
		var algo_length = path_lengths.get(algo)
		if typeof(algo_length) == TYPE_STRING:  # "No path"인 경우
			diff_counts[algo]["different"] += 1
			continue
			
		if algo_length == bfs_length:
			diff_counts[algo]["same"] += 1
		else:
			diff_counts[algo]["different"] += 1
			diff_counts[algo]["total_diff"] += abs(algo_length - bfs_length)

func print_statistics():
	print("\n=== Final Statistics (", TOTAL_TESTS, " tests) ===")
	for algo in diff_counts.keys():
		var stats = diff_counts[algo]
		var same_percent = (float(stats["same"]) / TOTAL_TESTS) * 100
		var diff_percent = (float(stats["different"]) / TOTAL_TESTS) * 100
		var avg_diff = 0.0 if stats["different"] == 0 else float(stats["total_diff"]) / stats["different"]
		
		print("\n" + algo + " vs BFS:")
		print("Same length: ", stats["same"], " (", snapped(same_percent, 0.1), "%)")
		print("Different length: ", stats["different"], " (", snapped(diff_percent, 0.1), "%)")
		if stats["different"] > 0:
			print("Average difference when different: ", snapped(avg_diff, 0.1), " cells")

func _on_path_finding_finished(success: bool, path: Array):
	var current_algo = algorithm_names[current_test_index]
	if success:
		path_lengths[current_algo] = path.size()
	else:
		path_lengths[current_algo] = "No path"
	
	# Clear visited cells and path
	await get_tree().create_timer(0.05).timeout
	EventBus.emit_signal("clear_visited_and_route")
	await get_tree().create_timer(0.05).timeout
	current_test_index += 1
	test_next_algorithm()

func _on_path_drawn(path: Array):
	pass
	
