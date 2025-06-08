extends IState


func enter(event): 
	# 우클릭일 때만 들어옴
	controller._apply_delete(event.position)
func update(event):
	
	# 탈출 조건에 대해 먼저 명시한다.

	# 우클릭 중 좌클릭 시
	if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# controller.change_state(controlle)
		return
	
	# 우클릭 종료 시
	if event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed:
		# controller.change_state(controlle)
		return

	# 우클릭 중 Space 시
	if event.button_index == KEY_SPACE and event.pressed:
		# controller.change_state(controlle)
		return
	
	controller._apply_delete(event.position)


func exit(event):
	# 얘는 뭐 딱히 건드는게 없음
	pass
