## Draws a rope onto a line with smoothing options
# Owned by: kaitaobenson

class_name RopeLineDrawer
extends Line2D

@export var rope: BaseRope

@export var smoothing_on: bool = false
@export var resolution_multiplier: float = 4.0

func _process(delta: float) -> void:
	if rope is VerletRope:
		if !rope.is_on_screen:
			visible = false
			return
	
	visible = true
	
	var raw_points = Util.smooth_line(rope.points, resolution_multiplier) if smoothing_on else rope.points
 
	# Convert to a modifiable Array[Vector2] with explicit typing
	var global_points: Array[Vector2] = []
	for p in raw_points:
		global_points.append(Vector2(p))
 
	# Override endpoints if needed
	if rope.start_pos_on and global_points.size() > 0:
		global_points[0] = rope.start_pos
	if rope.end_pos_on and global_points.size() > 1:
		global_points[global_points.size() - 1] = rope.end_pos
 
	# Convert to local space
	var local_points: Array[Vector2] = []
	for gp in global_points:
		local_points.append(to_local(gp))
 
	points = local_points
