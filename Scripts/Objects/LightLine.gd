# Owned by carsonetb
@tool
class_name LightLine
extends Node2D

@onready var line: Line2D = $Line
@export var directions: PackedVector2Array
var old_points: PackedVector2Array
var attachments: Array[PackedVector2Array]
var calculating := false

func _process(delta: float) -> void:
	if (attachments.is_empty() || old_points != line.points) && !calculating:
		recalculate_attachments()
		
	old_points = line.points.duplicate()
	queue_redraw()
	
func _draw() -> void:
	if attachments.size() < line.points.size() && !calculating:
		recalculate_attachments()
		return
	
	if calculating:
		for point in line.points:
			draw_circle(point, 6, Color(3.2, 3, 3))
		return
	
	var i := 0
	for point in line.points:
		for attachment in attachments[i]:
			draw_line(point, attachment, line.default_color, 4)
		draw_circle(point, 6, Color(3.2, 3, 3))
		i += 1

func recalculate_attachments():
	attachments = []
	calculating = true
	for point in line.points:
		var new: PackedVector2Array
		attachments.append(new)
		$Raycasts.global_position = global_position + point
		await get_tree().create_timer(0.5).timeout
		for raycast in $Raycasts.get_children():
			raycast = raycast as RayCast2D
			if raycast.is_colliding():
				var collider = raycast.get_collider()
				if collider is Submarine || collider is Diver:
					continue
				attachments[-1].append(to_local(raycast.get_collision_point()))
	calculating = false
