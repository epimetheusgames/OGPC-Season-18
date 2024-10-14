extends Node2D


func _process(delta: float) -> void:
	$Point.position = get_global_mouse_position()
	
	var closest_point_pos: Vector2
	var closest_point_dist := 99999999.0
	for i in range(len($Line2D.points)):
		var ideal_point_for_segment = Geometry2D.get_closest_point_to_segment($Point.position, $Line2D.points[i - 1], $Line2D.points[i])
		var dist = ideal_point_for_segment.distance_to($Point.position)
		if dist < closest_point_dist:
			closest_point_pos = ideal_point_for_segment
			closest_point_dist = dist
	
	# By some means find the two closest points.
	# Now find the closest point on that line.
	$EndPoint.position = closest_point_pos
