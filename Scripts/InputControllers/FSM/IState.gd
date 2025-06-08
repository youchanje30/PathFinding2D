extends Node
class_name IState

var controller : InputController

func init(p : InputController):
	controller = p

func enter(event): pass
func update(event): pass
func exit(event): pass
