class_name LightLineItem
extends BaseItem

@export var light_line_scene: PackedScene

func _ready() -> void:
	if process_mode == Node.PROCESS_MODE_DISABLED:
		return
	
	# Search for surrounding light lines.
	var found := false
	for light_line: LightLine in get_tree().get_nodes_in_group("light_lines"):
		var dist_first_squared := global_position.distance_squared_to(light_line.line.global_position + light_line.line.points[-1])
		var dist_last_squared := global_position.distance_squared_to(light_line.line.global_position + light_line.line.points[0])
		if dist_first_squared < light_line.min_point_dist ** 2 && dist_first_squared < dist_last_squared:
			light_line.line.add_point(global_position - light_line.line.global_position)
			found = true
		elif dist_last_squared < light_line.min_point_dist ** 2:
			light_line.line.add_point(global_position - light_line.line.global_position, 0)
			found = true
	
	# If none found, create a new light line.
	if !found: 
		var new_line: LightLine = light_line_scene.instantiate()
		get_parent().add_child(new_line)
		new_line.line.points = [Vector2.ZERO]
		new_line.global_position = global_position
	
	queue_free()
