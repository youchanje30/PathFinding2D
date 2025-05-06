## 우선순위 큐(Priority Queue) 클래스입니다.
## operator를 통해 최대/최소 힙을 선택할 수 있습니다.
## 기본 operator는 최소 힙입니다.
extends Node
class_name PQ

## 우선순위 큐를 저장하는 배열입니다.
var pq = []


## 비교 연산자 함수입니다. 기본값은 최소 힙입니다.
var operator = func(a, b): return a > b

## 큐를 초기화합니다.
func _init():
	pq = []


#region Comparator Methods
## 비교 연산자를 설정합니다.
func set_comparator(new_operator):
	operator = new_operator
#endregion



#region Priority Queue Methods
## 큐가 비어있는지 확인합니다.
## 비어있을 경우 True, 비어있지 않을 경우 False를 반환합니다.
func empty():
	return pq.is_empty()

## 큐의 최상위(우선순위가 가장 높은) 원소를 반환합니다.
func top():
	return pq[0]

## 조건에 맞는(우선순위가 가장 높은) 원소를 pop합니다.
func pop(): 
	pq[0] = pq[pq.size() - 1]
	adjust_heap(0, pq.size(), pq[0])
	pq.pop_back()

## 큐에 값을 추가합니다.
func push(val):
	pq.push_back(0)
	push_heap(pq.size()-1, val)

## 힙을 재정렬합니다. 내부적으로 사용됩니다.
func adjust_heap(holeIndex, last, val):
	var __secondChild = 2 * holeIndex + 2
	while __secondChild < last:
		if operator.call(pq[__secondChild], pq[__secondChild - 1]): __secondChild -= 1
		pq[holeIndex] = pq[__secondChild]
		holeIndex = __secondChild
		__secondChild = 2 * (__secondChild + 1)
	if __secondChild == last:   
		pq[holeIndex] = pq[__secondChild - 1]
		holeIndex = __secondChild - 1
	push_heap(holeIndex, val)

## 새로운 값을 힙에 맞게 삽입합니다. 내부적으로 사용됩니다.
func push_heap(holeIndex, val):
	var parent = (holeIndex - 1) / 2
	while 0 < holeIndex and operator.call(pq[parent], val):
		pq[holeIndex] = pq[parent]
		holeIndex = parent
		parent = (holeIndex - 1) / 2
	pq[holeIndex] = val

#endregion
