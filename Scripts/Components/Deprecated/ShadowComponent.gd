# DEPRECATED

class_name ShadowComponent
extends Node


var _polygon: Polygon2D

@export var shadow_color: Color
@export var offset_angle: float
@export var offset_length: float
@export var floating: bool = true
@export var attachable_polygon: Polygon2D
@export var debug_lines: Line2D

func _ready() -> void:
	_polygon = Polygon2D.new()
	_polygon.z_index = 2
	add_child(_polygon)
	
func _process(delta: float) -> void:
	if !attachable_polygon:
		return
		
	var vector_offset := Util.angle_to_vector(deg_to_rad(offset_angle), offset_length)
	
	if floating:
		_polygon.polygon = attachable_polygon.polygon
		_polygon.position = vector_offset
		_polygon.global_rotation = get_parent().global_rotation
	
	# Basically just reimplement shadows.
	else:
		var points_on_polygon: PackedVector2Array
		var points_offset: PackedVector2Array
		
		var first_point_on_polygon_index: int = 0
		var found_point_yet: bool = false
		
		for point_ind in range(attachable_polygon.polygon.size()):
			var point := attachable_polygon.polygon[point_ind]
			var shadow_end_for_point := point + vector_offset.normalized()
			var end_global := attachable_polygon.global_position + shadow_end_for_point
			var pointcast_results = Util.do_pointcast(attachable_polygon.get_world_2d(), end_global, 128)
			
			if !pointcast_results:
				points_on_polygon.append(point)
				points_offset.append(point + vector_offset)
				
				if !found_point_yet:
					found_point_yet = true
					first_point_on_polygon_index = point_ind
		
		# Fix an edge case ... This code is probably impossible to debug, but you're going to have 
		# to trust that it works. I'll give a little explanation though ... sometimes we miss a 
		# point on the polygon's edge but there's a simple way to fix that. Basically we loop 
		# through the polygon edge line, and for each point if it isn't at the same position as 
		# its corresponding polygon edge point we insert another point into the edge line which is 
		# the same as the edge point. This will cause problems with the for loop so we have to 
		# restart from the beginning. 
		var fixed: bool = false
		while !fixed:
			var reached_end = true
			for point_ind in range(points_on_polygon.size()):
				var point_on_polygon = attachable_polygon.polygon[point_ind + first_point_on_polygon_index]
				if points_on_polygon[point_ind] == point_on_polygon:
					continue
				else:
					# Insert into the line a point which is on the polygon.
					points_on_polygon.insert(point_ind, point_on_polygon)
					
					var line_intersect = Geometry2D.segment_intersects_segment(
							points_offset[point_ind - 1], points_offset[point_ind - 1] + (points_on_polygon[point_ind] - points_on_polygon[point_ind - 1]).normalized() * 99999,
							points_on_polygon[point_ind + 1], points_on_polygon[point_ind + 1] + (points_on_polygon[point_ind + 1] + vector_offset - points_on_polygon[point_ind + 1]).normalized() * 99999,
						)
						
					if !line_intersect:
						line_intersect = Geometry2D.segment_intersects_segment(
							points_on_polygon[point_ind + 1] + vector_offset, points_on_polygon[point_ind + 1] + vector_offset + (points_on_polygon[point_ind] - points_on_polygon[point_ind + 1]).normalized() * 99999,
							points_on_polygon[point_ind - 1], points_on_polygon[point_ind - 1] + (points_on_polygon[point_ind - 1] + vector_offset - points_on_polygon[point_ind - 1]).normalized() * 99999
						)
					
					points_offset.insert(
						point_ind, 
						line_intersect if line_intersect else points_on_polygon[point_ind] + vector_offset
					)
					reached_end = false
					break
			
			if reached_end:
				fixed = true
		
		var final_points: PackedVector2Array
		final_points.append_array(points_on_polygon)
		points_offset.reverse()
		final_points.append_array(points_offset)
		_polygon.polygon = final_points
		
		if debug_lines:
			debug_lines.points = final_points
		
		_polygon.position = attachable_polygon.global_position
		
	if debug_lines:
		debug_lines.position = _polygon.position
	_polygon.color = shadow_color
