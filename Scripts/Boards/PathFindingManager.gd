extends Node

class_name PathFindingManager

@export var path_finding_strategys : Array[IPathFindingStrategy]
@export var board_data : BoardData

func _ready():
	change_path_finding_strategy(0)


func _on_select_path_finding_item_selected(index: int) -> void:
	change_path_finding_strategy(index)

func change_path_finding_strategy(index : int):
	board_data.change_path_find_strategy(path_finding_strategys[index])
