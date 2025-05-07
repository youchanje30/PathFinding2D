extends Node

@export var test_input : Array[int]
var test_data_set : Array[int]


var pq := PQ.new()

func _ready():
	pq.set_comparator(comparator.greater)
	
	for item in test_input:
		pq.push(item)

	while not pq.empty():
		print(pq.top())
		pq.pop()

	test()
	test_by_array_element()

func test():
	print("1 ~ 100까지의 수를 랜덤하게 20회 삽입 후 빼는 연산을 진행합니다")

	for i in range(20): pq.push(randi_range(1, 100))
	while not pq.empty(): print(pq.top()); pq.pop()

func test_by_array_element():
	print("\n 가중치와 vector가 포함된 배열을 랜덤하게 20회 삽입 후 빼는 연산을 진행합니다")
	for i in range(20):
		var weight = randi_range(1, 100)
		var vector = Vector2(randi_range(1, 100), randi_range(1, 100))
		pq.push([weight, vector])

	while not pq.empty(): print(pq.top()); pq.pop()
