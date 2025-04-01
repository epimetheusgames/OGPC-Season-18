# Owned by carsonetb
@tool
class_name LightLine
extends Node2D

@onready var line: Line2D = $Line
@export var directions: PackedVector2Array
@export var min_point_dist: float = 300
var old_points: PackedVector2Array
var attachments: Array[PackedVector2Array]
var calculating := false

func _ready() -> void:
	Global.save_load_framework.save_nodes.connect(_save)

func _process(_delta: float) -> void:
	if (attachments.is_empty() || old_points != line.points) && !calculating:
		recalculate_attachments()
		
	old_points = line.points.duplicate()
	queue_redraw()
	
func _draw() -> void:
	if attachments.size() < line.points.size() && !calculating:
		recalculate_attachments()
		return
	
	var i := -1
	for point in line.points:
		i += 1
		if i >= attachments.size():
			draw_circle(point, 6, Color(3.2, 3, 3))
			continue
		for attachment in attachments[i]:
			draw_line(point, attachment, line.default_color, 4)
		draw_circle(point, 6, Color(3.2, 3, 3))

func recalculate_attachments():
	var new_attachments: Array[PackedVector2Array] = []
	calculating = true
	var i := -1
	for point in line.points:
		i += 1
		var new: PackedVector2Array
		new_attachments.append(new)
		$Raycasts.global_position = global_position + point
		await get_tree().create_timer(0.5).timeout
		for raycast in $Raycasts.get_children():
			raycast = raycast as RayCast2D
			if raycast.is_colliding():
				var collider = raycast.get_collider()
				if collider is Submarine || collider is Diver:
					continue
				new_attachments[-1].append(to_local(raycast.get_collision_point()))
	calculating = false
	attachments = new_attachments

func _save() -> void:
	Global.current_game_save.node_saves.append(NodeSaver.create(Global.current_mission_node, self, ["old_points", "attachments", "calculating"]))