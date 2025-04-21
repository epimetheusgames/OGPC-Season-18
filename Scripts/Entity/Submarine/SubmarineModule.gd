extends Node2D
class_name SubmarineModule

@export var path : FilePathResource

@export var rotation_increment = 90

var attachment_points : Array[AttachmentPoint]
var render_attachment_points := false
var is_editor_peice := false
var mouse_in_area := false
var selected := false
var grid_position : Vector2i

func _ready() -> void:
	var navigation_obstacle = StaticBody2D.new()
	navigation_obstacle.name = "NavigationObstacle"
	navigation_obstacle.collision_layer = 10000
	navigation_obstacle.collision_mask = 0
	navigation_obstacle.add_to_group("obstacles")
	add_child(navigation_obstacle, true)
	
	if get_node_or_null("AttachmentPoints"):
		for child in $"AttachmentPoints".get_children():
			attachment_points.append(child)
	
	if get_node_or_null("Collision") && $"../.." is Submarine:
		for child in get_node_or_null("Collision").get_children():
			var old_pos: Vector2 = child.global_position
			var old_rot: float = child.global_rotation
			$NavigationObstacle.add_child(child.duplicate())
			$"Collision".remove_child(child)
			$"../..".add_child(child) 
			child.global_position = old_pos
			child.global_rotation = old_rot
	
	if get_node_or_null("ModuleArea") && $"../.." is Submarine:
		for child in get_node_or_null("ModuleArea").get_children():
			var old_rot: float = child.global_rotation
			$"ModuleArea".remove_child(child)
			$"../../SubmarineArea".add_child(child)
			child.position += self.position - $"../".control_module_position
			child.global_rotation = old_rot
	
	$ModuleArea.area_entered.connect(_area_mouse_entered)
	$ModuleArea.area_exited.connect(_area_mouse_exited)

func _process(delta: float) -> void:
	if !is_editor_peice:
		if Global.player.get_state() == Diver.DiverState.IN_SUBMARINE:
			for child in $NavigationObstacle.get_children():
				child.disabled = true
		else:
			for child in $NavigationObstacle.get_children():
				child.disabled = false
	
	var editor: SubmarineEditor
	if is_editor_peice:
		editor = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()
	if mouse_in_area && is_editor_peice && Input.is_action_just_pressed("mouse_left_click") && !editor.module_adding == self:
		for child in get_parent().get_children():
			if child is SubmarineModule && child != self:
				child.selected = false
		selected = !selected
	
	if selected:
		modulate = Color(1.5, 1.5, 1.5)
		
		if Input.is_action_just_pressed("ui_text_backspace"):
			editor.modules.remove_at(editor.modules.find(self))
			editor.module_grid[grid_position.y][grid_position.x] = null
			if self is SubmarineControlModule:
				editor.has_control_module = false
				editor.control_module_position = Vector2()
			queue_free()
	else:
		modulate = Color(1, 1, 1)
	
	queue_redraw()

func _area_mouse_entered(area) -> void:
	if area.name == "MouseArea":
		mouse_in_area = true

func _area_mouse_exited(area) -> void:
	if area.name == "MouseArea":
		mouse_in_area = false

func rotate_module() -> void:
	rotation += deg_to_rad(rotation_increment)
	for point in attachment_points:
		point.direction = point.direction.length() * Vector2.from_angle(point.direction.angle() + deg_to_rad(rotation_increment))

func create_module_resource() -> SubmarineModuleResource:
	var module_resource = SubmarineModuleResource.new()
	module_resource.module_scene = path
	module_resource.position = position
	module_resource.rotation = rotation
	module_resource.grid_position = grid_position
	for point in attachment_points:
		var attachment_point_resource := AttachmentPointResource.new()
		attachment_point_resource.position = point.position
		attachment_point_resource.direction = point.direction
		attachment_point_resource.is_attached = point.is_attached
		module_resource.attachment_points.append(attachment_point_resource)
	
	return module_resource

func _draw() -> void:
	if !render_attachment_points:
		return
	
	for point in attachment_points:
		draw_circle(point.position, 10, Color.WHITE, false, 2)
		draw_line(point.position, point.position + point.direction.rotated(-rotation) * 50, (Color.GREEN if point.is_attached else Color.RED), 2)
