class_name SubmarineEditor
extends Control


@onready var origin = $"SplitContainer/SubmarineView/Origin"
@onready var grid = $"SplitContainer/PanelContainer/VSplitContainer/GridContainer"

@onready var control_module := preload("res://Scenes/TSCN/Entities/Submarine/SubmarineModules/SubmarineControlModule.tscn")
@onready var submarine_L_passage_module := preload("res://Scenes/TSCN/Entities/Submarine/SubmarineModules/SubmarineLPassageModule.tscn")
@onready var submarine_rl_passage_module := preload("res://Scenes/TSCN/Entities/Submarine/SubmarineModules/SubmarineRlPassageModule.tscn")
@onready var submarine_ud_passage_module := preload("res://Scenes/TSCN/Entities/Submarine/SubmarineModules/SubmarineUDPassageModule.tscn")

var modules: Array[SubmarineModule] = []
var adding_module := false
var module_adding: SubmarineModule

func add_module(new_module: SubmarineModule):
	adding_module = true
	new_module.render_attachment_points = true
	origin.add_child(new_module)
	module_adding = new_module
	modules.append(new_module)

func _on_control_module_button_up() -> void:
	add_module(control_module.instantiate())

func _on_ud_passage_module_button_up() -> void:
	add_module(submarine_L_passage_module.instantiate())

func _on_l_passage_module_button_up() -> void:
	add_module(submarine_rl_passage_module.instantiate())

func _on_rl_passage_module_button_up() -> void:
	add_module(submarine_ud_passage_module.instantiate())

func _process(delta: float) -> void:
	if adding_module:
		var valid_point: AttachmentPoint = null
		var our_valid_point: AttachmentPoint = null
		for module in modules:
			if module == module_adding:
				continue
			for point in module.attachment_points:
				for our_point in module_adding.attachment_points:
					if point.direction == -our_point.direction && point.global_position.distance_to(our_point.global_position) < 100 && !point.attached_point && !our_point.attached_point:
						valid_point = point
						our_valid_point = our_point
		
		module_adding.global_position = get_global_mouse_position()
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
	
	queue_redraw()

func _draw() -> void:
	if adding_module:
		for module in modules:
			if module == module_adding:
				continue
			for point in module.attachment_points:
				for our_point in module_adding.attachment_points:
					if point.direction == -our_point.direction && point.global_position.distance_to(our_point.global_position) < 100 && !point.attached_point && !our_point.attached_point:
						draw_line(our_point.global_position - global_position, point.global_position - global_position, Color.RED, 2)

func _on_save_button_button_up() -> void:
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
	print(ResourceSaver.save(sub_resource, path))

func _on_load_dialog_file_selected(path: String) -> void:
	pass # Replace with function body.
