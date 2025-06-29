extends IState

func enter(event):
	controller.find_path()

func update(event):
	if controller.input.can_fix:
		controller.change_state(controller.STATE_IDLE)
		return
	
	if event is not InputEventKey: return

	if event.keycode == KEY_SPACE and event.pressed:
		controller.change_state(controller.STATE_IDLE)
		

func exit():
	controller.find_path()
