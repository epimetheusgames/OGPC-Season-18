# Owned by carsonetb
class_name SubmarineEditor
extends Control

@onready var origin = $"SplitContainer/SubmarineView/ViewContainer/Viewport/Origin"
@onready var grid = $"SplitContainer/PanelContainer/VSplitContainer/GridContainer"

@onready var control_module := preload("res://Scenes/TSCN/Entities/Submarine/SubmarineModules/SubmarineControlModule.tscn")
@onready var submarine_corner_passage_module := preload("res://Scenes/TSCN/Entities/Submarine/SubmarineModules/SubmarineCornerPassageModule.tscn")
@onready var submarine_passage_module := preload("res://Scenes/TSCN/Entities/Submarine/SubmarineModules/SubmarinePassageModule.tscn")
@onready var submarine_end_module := preload("res://Scenes/TSCN/Entities/Submarine/SubmarineModules/SubmarineEndModule.tscn")
@onready var submarine_door_module := preload("res://Scenes/TSCN/Entities/Submarine/SubmarineModules/SubmarineDoorModule.tscn")
@onready var submarine_weapons_module := preload("res://Scenes/TSCN/Entities/Submarine/SubmarineModules/SubmarineWeaponsModule.tscn")

var modules: Array[SubmarineModule] = []
var adding_module := false
var module_adding: SubmarineModule

func add_module(new_module: SubmarineModule):
	adding_module = true
	new_module.render_attachment_points = true
	new_module.is_editor_peice = true
	origin.add_child(new_module)
	module_adding = new_module
	modules.append(new_module)

func _on_control_module_button_up() -> void:
	if !adding_module:
		add_module(control_module.instantiate())

func _on_corner_passage_module_button_up() -> void:
	if !adding_module:
		add_module(submarine_corner_passage_module.instantiate())

func _on_passage_module_button_up() -> void:
	if !adding_module:
		add_module(submarine_passage_module.instantiate())

func _on_end_passage_module_button_up() -> void:
	if !adding_module:
		add_module(submarine_end_module.instantiate())

func _on_door_module_button_up() -> void:
	if !adding_module:
		add_module(submarine_door_module.instantiate())

func _on_weapons_module_button_up() -> void:
	if !adding_module:
		add_module(submarine_weapons_module.instantiate())

func _process(delta: float) -> void:
	if adding_module:
		var valid_point: AttachmentPoint = null
		var our_valid_point: AttachmentPoint = null
		for module in modules:
			if module == module_adding:
				continue
			for point in module.attachment_points:
				for our_point in module_adding.attachment_points:
					if point.direction.is_equal_approx(-our_point.direction) && point.global_position.distance_to(our_point.global_position) < 100 && !point.attached_point && !our_point.attached_point:
						valid_point = point
						our_valid_point = our_point
		
		module_adding.global_position = module_adding.get_global_mouse_position()
		if Input.is_action_just_pressed("mouse_left_click"):
			if modules.size() == 1:
				module_adding = null
				adding_module = false
			elif valid_point:
				module_adding.position += (valid_point.global_position - our_valid_point.global_position)
				valid_point.attached_point = our_valid_point
				our_valid_point.attached_point = valid_point
				module_adding = null
				adding_module = false
		if Input.is_action_just_pressed("rotate_peice"):
			module_adding.rotate_module(PI / 2)
	if Input.is_action_just_pressed("mwUP"):
		$SplitContainer/SubmarineView/ViewContainer/Viewport/Camera2D.zoom *= 1.1
	if Input.is_action_just_pressed("mwDOWN"):
		$SplitContainer/SubmarineView/ViewContainer/Viewport/Camera2D.zoom *= 0.9
	
	queue_redraw()

#func _draw() -> void:
	#if adding_module:
		#for module in modules:
			#if module == module_adding:
				#continue
			#for point in module.attachment_points:
				#for our_point in module_adding.attachment_points:
					#if point.direction.is_equal_approx(-our_point.direction) && point.global_position.distance_to(our_point.global_position) < 100 && !point.attached_point && !our_point.attached_point:
						#draw_line(our_point.global_position - global_position, point.global_position - global_position, Color.RED, 2)

func find_assosiated_point(point: Vector2, direction: Vector2, multiplier: int = 1) -> AttachmentPoint:
	for module in modules:
		for real_point in module.attachment_points:
			if real_point.global_position.distance_to(point) < 1 && real_point.direction.is_equal_approx(direction * multiplier):
				return real_point
	return null

# TODO: Add more stuff here.
func do_submarine_sanity_checks() -> bool:
	for module in modules:
		for point in module.attachment_points:
			if !point.attached_point:
				return false
	return true

func _on_save_button_button_up() -> void:
	if !do_submarine_sanity_checks():
		print("WARNING: Invalid submarine.")
		return
		
	$SaveDialog.visible = true

func _on_load_button_button_up() -> void:
	$LoadDialog.visible = true

func _on_save_dialog_file_selected(path: String) -> void:
	var sub_resource = CustomSubmarineResource.new()
	for module in modules:
		sub_resource.modules.append(module.create_module_resource())
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string("")
	file.close()
	ResourceSaver.save(sub_resource, path)

func _on_load_dialog_file_selected(path: String) -> void:
	var sub_resource: CustomSubmarineResource = ResourceLoader.load(path)
	
	# Pass 1, load module positions.
	for module in sub_resource.modules:
		var new_module: SubmarineModule = load(module.module_scene.file).instantiate()
		new_module.position = module.position
		new_module.render_attachment_points = true
		origin.add_child(new_module)
		modules.append(new_module)
	
	# Pass two, load connections.
	for module in sub_resource.modules:
		for attachment_resource in module.attachment_points:
			if attachment_resource.is_attached:
				var real_point := find_assosiated_point(attachment_resource.position + module.position + origin.global_position, attachment_resource.direction)
				real_point.attached_point = find_assosiated_point(attachment_resource.position + module.position + origin.global_position, attachment_resource.direction, -1)
