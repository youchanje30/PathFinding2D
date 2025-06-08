extends IState

func enter(event):
	# 좌클릭일 때만 해당 상태로 들어온다 (생성이기 때문에 오른클릭은 무시)
	controller.is_left_dragging = true
	
	match controller.mode:
		controller.MODE_START_END:
			controller._apply_start_end(event.position)
		controller.MODE_WALL:
			controller._apply_wall(event.position, true)
		controller.MODE_WEIGHT:
			controller._apply_weight(event.position)

func update(event):
	# 탈출 조건에 대해 먼저 명시한다.

	# 좌클릭 종료 시
	if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		# controller.change_state(controlle)
		return
	
	# 좌클릭 중 오른클릭 시
	if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		# controller.change_state(controlle)
		return

	# 좌클릭 중 Space 시
	if event.button_index == KEY_SPACE and event.pressed:
		# controller.change_state(controlle)
		return

	# 모드 변경은 그냥 알아서 처리

	match controller.mode:
		controller.MODE_START_END:
			controller._apply_start_end(event.position)
		controller.MODE_WALL:
			controller._apply_wall(event.position, true)
		controller.MODE_WEIGHT:
			controller._apply_weight(event.position)

func exit(event):
	controller.is_left_dragging = false
	return
