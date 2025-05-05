extends Node
class_name PQ

var pq = []
var operator = func(a, b): return a < b



func _init():
    pq = []

func is_empty():
    return pq.empty()

func top():
    return pq[0]

func pop():
    pq[0] = pq[pq.size() - 1]
    pq.pop_back()
    adjust_heap(0, pq.size())

func push(item):
    pq.append(item)
    push_heap(0, pq.size() - 1)

func adjust_heap(first, last):
    var __secondChild = 2 * first + 2
    while __secondChild < last:
        if operator.call(pq[__secondChild], pq[__secondChild - 1]):
            __secondChild -= 1
        pq[first] = pq[__secondChild]
        first = __secondChild
        __secondChild = 2 * (__secondChild + 1)
    if __secondChild == last:
        pq[first] = pq[__secondChild - 1]
        first = __secondChild - 1
    push_heap(first, pq[first])

func push_heap(target, value):
    var parent = (target - 1) / 2
    while 0 < target and operator.call(pq[parent], value):
        pq[target] = pq[parent]
        target = parent
        parent = (target - 1) / 2
    pq[target] = value

