class_name RopeLineDrawer
extends Line2D

@export var rope: BaseRope

@export var smoothing_on: bool = false
@export var resolution_multiplier: float = 1.0

func _process(delta: float) -> void:
	if smoothing_on:
		points = Util.smooth_line(points, resolution_multiplier)
