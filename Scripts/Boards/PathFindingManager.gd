extends Node

class_name PathFindingManager

@export var path_finding_strategys : Array[IPathFindingStrategy]

func _ready():
	change_path_finding_strategy(0)

func _on_select_path_finding_item_selected(index: int) -> void:
	change_path_finding_strategy(index)

func change_path_finding_strategy(index : int):
	EventBus.emit_signal("path_finding_strategy_changed", path_finding_strategys[index])


func _on_select_delay_item_selected(index: int) -> void:
	EventBus.emit_signal("delay_strategy_changed", index)
