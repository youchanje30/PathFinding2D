## PQ의 연산자를 위한 compartor
extends Node
class_name comparator


## 최소 힙에 사용되는 비교 함수
static func less(a, b): return a > b
## 최대 힙에 사용되는 비교 함수
static func greater(a, b): return a < b

## 첫 번째 요소를 기준으로 비교하는 함수
static func less_by_first(a, b): return a[0] > b[0]
## 첫 번째 요소를 기준으로 비교하는 함수
static func greater_by_first(a, b): return a[0] < b[0]

