## Draws a rope onto a line with smoothing options
# Owned by: kaitaobenson

class_name RopeLineDrawer
extends Line2D

@export var rope: BaseRope

@export var smoothing_on: bool = false
@export var resolution_multiplier: float = 4.0

func _process(delta: float) -> void:
	if smoothing_on:
		points = Util.smooth_line(rope.points, resolution_multiplier)
	else:
		points = rope.points
