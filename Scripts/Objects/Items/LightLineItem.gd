class_name LightLineItem
extends BaseItem

@export var light_line_scene: PackedScene

func _ready() -> void:
	if process_mode == Node.PROCESS_MODE_DISABLED:
		return
	
	# Search for surrounding light lines.
	var found := false
	for light_line: LightLine in get_tree().get_nodes_in_group("light_lines"):
		if global_position.distance_squared_to(light_line.line.global_position + light_line.line.points[0]) < light_line.min_point_dist ** 2:
			light_line.line.points.insert(0, global_position - light_line.line.global_position)
			found = true
		if global_position.distance_squared_to(light_line.line.global_position + light_line.line.points[-1]) < light_line.min_point_dist ** 2:
			light_line.line.points.append(global_position - light_line.line.global_position)
			found = true
	
	# If none found, create a new light line.
	if !found: 
		var new_line: LightLine = light_line_scene.instantiate()
		get_parent().add_child(new_line)
		new_line.global_position = global_position
	
	queue_free()
