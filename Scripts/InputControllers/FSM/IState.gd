extends Node
class_name IState

var controller : StateController

func init(p : StateController):
	controller = p

func enter(event): pass
func update(event): pass
func exit(): pass
