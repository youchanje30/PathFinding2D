extends IState

func enter(event):
	# 좌클릭일 때만 해당 상태로 들어온다 (생성이기 때문에 오른클릭은 무시)
	
	match controller.input.mode:
		controller.input.MODE_START_END:
			controller.apply_start_end(event.position)
		controller.input.MODE_WALL:
			controller.apply_wall(event.position, true)
		controller.input.MODE_WEIGHT:
			controller.apply_weight(event.position)

func update(event):
	# 탈출 조건에 대해 먼저 명시한다.
	
	# 좌클릭 중 Space 시
	if event is InputEventKey:
		if event.keycode == KEY_SPACE and event.pressed:
			controller.change_state(controller.STATE_IN_PLAY)
		return
        
	if event is not InputEventMouseButton:
		return

	# 좌클릭 종료 시
	if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		controller.change_state(controller.STATE_IDLE)
		return
	
	# 좌클릭 중 오른클릭 시
	if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		controller.change_state(controller.STATE_REMOVE)
		return


	match controller.input.mode:
		controller.input.MODE_START_END:
			controller.apply_start_end(event.position)
		controller.input.MODE_WALL:
			controller.apply_wall(event.position, true)
		controller.input.MODE_WEIGHT:
			controller.apply_weight(event.position)

func exit():
	return
