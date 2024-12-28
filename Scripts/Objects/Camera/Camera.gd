extends Camera2D

@export var target_node: Node2D

func _process(_delta: float) -> void:
	global_position = target_node.global_position
