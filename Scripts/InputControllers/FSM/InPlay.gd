extends IState

func enter(event):
	controller.can_fix = false
	controller._find_path()

func update(event):
	if event.keycode == KEY_SPACE and event.pressed:
		# controller.change_state(controlle)
		return
	
	if controller.can_fix:
		# controller.change_state(controlle)
		return
		

func exit(event):
	controller.can_fix = true
