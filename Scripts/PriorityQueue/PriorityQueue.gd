## 우선순위 큐 구현
## operator를 통해 최대/최소 힙을 선택할 수 있습니다 (기본값: 최소 힙)
## 시간 복잡도: push O(log n), pop O(log n), top O(1)
extends Node
class_name PriorityQueue

## 힙 저장을 위한 내부 배열
var pq: Array = []

## 현재 힙의 크기
var _size: int = 0

## 비교 연산자 함수
## 기본값은 최소 힙 (a > b)
var operator: Callable = func(a: Variant, b: Variant) -> bool: return a > b

## 빈 우선순위 큐를 초기화합니다
func _init() -> void:
	pq = []
	_size = 0

## 비교 연산자 함수를 설정합니다
## @param new_operator: Callable - 새로운 비교 함수
func set_comparator(new_operator: Callable) -> void:
	operator = new_operator

## 큐가 비어있는지 확인합니다
## @return bool - 비어있으면 true, 아니면 false
func empty() -> bool:
	return _size == 0

## 최상위 원소를 반환합니다 (제거하지 않음)
## @return Variant - 우선순위가 가장 높은 원소
## @throws - 큐가 비어있을 경우 에러
func top() -> Variant:
	if empty():
		push_error("Cannot get top element from empty queue")
		return null
	return pq[0]

## 최상위 원소를 제거합니다
## @throws - 큐가 비어있을 경우 에러
func pop() -> void:
	if empty():
		push_error("Cannot pop from empty queue")
		return
	
	pq[0] = pq[_size - 1]
	_size -= 1
	if not empty():
		adjust_heap(0, _size, pq[0])
	pq.pop_back()

## 큐에 새로운 원소를 추가합니다
## @param val: Variant - 추가할 원소
func push(val: Variant) -> void:
	if _size == pq.size():
		pq.push_back(val)
	else:
		pq[_size] = val
	push_heap(_size, val)
	_size += 1

## 힙 속성을 유지하기 위한 내부 메서드
## @private
func adjust_heap(hole_index: int, last: int, val: Variant) -> void:
	var child_index := 2 * hole_index + 2
	
	while child_index < last:
		if operator.call(pq[child_index], pq[child_index - 1]):
			child_index -= 1
		pq[hole_index] = pq[child_index]
		hole_index = child_index
		child_index = 2 * (child_index + 1)
	
	if child_index == last:
		pq[hole_index] = pq[child_index - 1]
		hole_index = child_index - 1
	
	push_heap(hole_index, val)

## 힙 속성을 유지하며 새로운 값을 삽입하는 내부 메서드
## @private
func push_heap(hole_index: int, val: Variant) -> void:
	var parent_index := (hole_index - 1) / 2
	
	while hole_index > 0 and operator.call(pq[parent_index], val):
		pq[hole_index] = pq[parent_index]
		hole_index = parent_index
		parent_index = (hole_index - 1) / 2
	
	pq[hole_index] = val

## 힙 속성이 유지되는지 검증하는 메서드
## @return bool - 힙 속성이 유지되면 true, 아니면 false
func verify_heap() -> bool:
	for i in range(1, _size):
		var parent_index := (i - 1) / 2
		if operator.call(pq[parent_index], pq[i]):
			return false
	return true

## 현재 큐의 크기를 반환합니다
## @return int - 큐에 있는 원소의 개수
func size() -> int:
	return _size

## 큐의 모든 원소를 제거합니다
func clear() -> void:
	pq.clear()
	_size = 0
