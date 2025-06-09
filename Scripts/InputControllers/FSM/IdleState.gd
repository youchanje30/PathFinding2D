extends IState

func enter(event):
	# Idle 상태 진입 시 초기화 필요시 작성
	pass

func update(event):
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				controller.change_state(controller.STATE_GENERATE, event)
			MOUSE_BUTTON_RIGHT:
				controller.change_state(controller.STATE_REMOVE, event)	
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		controller.change_state(controller.STATE_IN_PLAY)
		

func exit():
	# Idle 상태에서 나갈 때 정리 필요시 작성
	pass 
