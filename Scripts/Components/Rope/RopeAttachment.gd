## You can attach stuff to ropes if you want.
# Owned by: kaitaobenson

class_name RopeAttachment
extends Node2D

@export var rope: BaseRope
@export var rope_node_index: int
@export var attachment_pos: Vector2

func _ready() -> void:
	# Make sure is valid rope_node
	var clamp: int = clamp(rope_node_index, 0, rope.point_amount - 1)
	
	if (rope_node_index != clamp):
		printerr("RopeAttachment rope_node_index was out of bounds")
		rope_node_index = clamp

func _process(delta: float) -> void:
	var attach_node: Vector2 = rope.points[rope_node_index]
	
	# Get 2 adjacent node's position to get angle
	var node1: Vector2
	var node2: Vector2
	
	if rope_node_index == rope.point_amount - 1:
		node1 = rope.points[rope_node_index - 1]
		node2 = attach_node
	else:
		node1 = rope.points[rope_node_index + 1]
		node2 = attach_node
	
	var angle: float = node1.angle_to_point(node2) + PI/2
	
	# Calculate final attached position
	global_position = attachment_pos.rotated(angle) + attach_node
