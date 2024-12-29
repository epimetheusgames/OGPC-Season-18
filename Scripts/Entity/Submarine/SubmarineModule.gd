extends Node2D
class_name SubmarineModule

@export var path : FilePathResource

var attachment_points : Array[AttachmentPoint]
var attachment_point_resources : Array[AttachmentPointResource]
var render_attachment_points := false

func _ready() -> void:
	if get_node_or_null("AttachmentPoints"):
		for child in $"AttachmentPoints".get_children():
			attachment_points.append(child)
	
	if get_node_or_null("Collision") && $"../.." is Submarine:
		for child in get_node_or_null("Collision").get_children():
			$"Collision".remove_child(child)
			$"../..".add_child(child) 
			child.position += self.position
	
	if get_node_or_null("ModuleArea") && $"../.." is Submarine:
		for child in get_node_or_null("ModuleArea").get_children():
			$"ModuleArea".remove_child(child)
			$"../../SubmarineArea".add_child(child)
			child.position += self.position

func _process(delta: float) -> void:
	queue_redraw()

func create_module_resource() -> SubmarineModuleResource:
	var scene = path.file
	var module_resource = SubmarineModuleResource.new()
	module_resource.module_scene = scene
	module_resource.position = Vector2(0,0)
	for point in attachment_points:
		var attachment_point_resource : AttachmentPointResource
		attachment_point_resource.position = point.position
		attachment_point_resource.direction = point.direction
		module_resource.attachment_points.append(attachment_point_resource)
	
	return module_resource

func _draw() -> void:
	if !render_attachment_points:
		return
	
	for point in attachment_points:
		draw_circle(point.position, 10, Color.WHITE, false, 2)
		draw_line(point.position, point.position + point.direction * 50, Color.WHITE, 2)
