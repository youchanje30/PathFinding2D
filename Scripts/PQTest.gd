extends Node

@export var test_input : Array[int]
var test_data_set : Array[int]


var pq := PQ.new()

func _ready():
	for item in test_input:
		pq.push(item)

	while not pq.empty():
		print(pq.top())
		pq.pop()

	test()

func test():
	print("1~100 까지의 랜덤한 수에 대해 30회 동안 랜덤하게 삽입과 삭제를 진행합니다.")

	for i in range(30):
		if randi_range(1, 2) % 2 == 0 and not pq.empty():
			print(pq.top())
			pq.pop()
		else:
			pq.push(randi_range(1, 100))
