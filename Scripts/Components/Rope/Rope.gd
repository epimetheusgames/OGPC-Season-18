## Base class for ropes.
## Ropes must update 'points' and be go from 'start_node' to 'end_node'

class_name Rope
extends Node2D

@export var point_amount: int = 100
@export var point_separation: float = 10.0

# Optional, you can set 'start_pos' or 'end_pos' directly
@export var start_anchor_node: Node2D
@export var end_anchor_node: Node2D

var start_pos: Vector2 = Vector2()
var start_pos_on: bool = false

var end_pos: Vector2 = Vector2()
var end_pos_on: bool = false

var points: Array[Vector2]

func _ready():
	points.resize(point_amount)
	points.fill(Vector2(0, 0))
	
	if start_anchor_node:
		start_pos_on = true
	if end_anchor_node:
		end_pos_on = true

func _process(delta: float) -> void:
	if start_anchor_node:
		start_pos = start_anchor_node.global_position
	if end_anchor_node:
		end_pos = end_anchor_node.global_position
