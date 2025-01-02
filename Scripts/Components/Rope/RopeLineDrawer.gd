## Draws a rope onto a line with smoothing options
# Owned by: kaitaobenson

class_name RopeLineDrawer
extends Line2D

@export var rope: BaseRope

@export var smoothing_on: bool = false
@export var resolution_multiplier: float = 4.0

func _ready() -> void:
	top_level = true

func _process(delta: float) -> void:
	if "is_on_screen" in rope && !rope.get("is_on_screen"):
		visible = false
		return
	
	visible = true
	
	if smoothing_on:
		points = Util.smooth_line(rope.points, resolution_multiplier)
		if rope.start_pos_on:
			points[0] = rope.start_pos
		if rope.end_pos_on:
			points[-1] = rope.end_pos
	else:
		points = rope.points
