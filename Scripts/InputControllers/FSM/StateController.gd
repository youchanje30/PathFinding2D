extends Node
class_name StateController

@export var input : InputController

@export var states : Array[IState] = []
var current_state : IState = null

const STATE_IDLE = 0
const STATE_GENERATE = 1
const STATE_REMOVE = 2
const STATE_IN_PLAY = 3


func _ready():
	for s in states: s.init(self)
	# IdleState를 기본 상태로 설정
	change_state(STATE_IDLE)

func handle_input(event):
	if not current_state: change_state(STATE_IDLE)

	current_state.update(event)

func change_state(new_state : int, event = null):
	if current_state: current_state.exit()
	current_state = states[new_state]
	current_state.enter(event)

#region InputController의 주요 기능을 StateController에서 래핑
func set_cell(x, y, state, cost=1):
	if input:
		input.set_cell(x, y, state, cost)

func remove_cell(x, y):
	if input:
		input.remove_cell(x, y)

func find_path():
	if input:
		input._find_path()

func apply_wall(mouse_pos, is_create):
	if input: input._apply_wall(mouse_pos, is_create)

func apply_weight(mouse_pos):
	if input: input._apply_weight(mouse_pos)

func apply_start_end(mouse_pos):
	if input: input._apply_start_end(mouse_pos)

func apply_delete(mouse_pos):
	if input: input._apply_delete(mouse_pos)

func get_position(mouse_pos):
	if input: return input.get_position(mouse_pos)
	return null

func get_mode():
	return input.mode
#endregion
