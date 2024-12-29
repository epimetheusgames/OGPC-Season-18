class_name SubmarineEditor
extends Control


@onready var origin = $"SplitContainer/SubmarineView/Origin"
@onready var grid = $"SplitContainer/PanelContainer/GridContainer"

@onready var control_module = preload("res://Scenes/TSCN/Entities/Submarine/SubmarineControlModule.tscn")

var modules: Array[SubmarineModule] = []
var adding_module := false
var module_adding: SubmarineModule

func _on_control_module_button_up() -> void:
	adding_module = true
	var new_module: SubmarineModule = control_module.instantiate()
	new_module.render_attachment_points = true
	origin.add_child(new_module)
	module_adding = new_module
	modules.append(new_module)

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
						draw_line(our_point.global_position - global_position, point.global_position - global_position, Color.RED, 2)
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
		draw_circle(get_local_mouse_position(), 10, Color.WHITE, false, 2)
		for module in modules:
			if module == module_adding:
				continue
			for point in module.attachment_points:
				for our_point in module_adding.attachment_points:
					if point.direction == -our_point.direction && point.global_position.distance_to(our_point.global_position) < 100 && !point.attached_point && !our_point.attached_point:
						draw_line(our_point.global_position - global_position, point.global_position - global_position, Color.RED, 2)
