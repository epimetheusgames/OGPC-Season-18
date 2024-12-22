class_name LeviathanNode
extends CollisionShape2D

@export var is_start_node: bool = false
var target_node: Node2D

func set_target_node(target_node: Node2D):
	self.target_node = target_node

func _process(delta: float) -> void:
	if (!is_start_node):
		rotation = global_position.angle_to_point(target_node.global_position)
