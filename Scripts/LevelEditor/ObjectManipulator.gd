extends Node2D


var object_manipulating: Node2D
var x_axis_moving := false
var y_axis_moving := false
var both_moving := false
var rotating := false
var snapping_ammount := 16

func set_object(object: Node2D):
	object_manipulating = object
	position = object_manipulating.position
	visible = true

func _process(delta: float) -> void:
	if object_manipulating:
		if Input.is_action_pressed("control_key"):
			if x_axis_moving:
				position.x = snapping_ammount * round(get_global_mouse_position().x / snapping_ammount)
			if y_axis_moving:
				position.y = snapping_ammount * round(get_global_mouse_position().y / snapping_ammount)
			if both_moving:
				position = snapping_ammount * round(get_global_mouse_position() / snapping_ammount)
		else:
			if x_axis_moving:
				position.x = get_global_mouse_position().x
			if y_axis_moving:
				position.y = get_global_mouse_position().y
			if both_moving:
				position = get_global_mouse_position()
			if rotating:
				# This is complicated, figure it out later ...
				pass
		
		object_manipulating.position = position
	else:
		visible = false

func _on_x_axis_button_down() -> void:
	x_axis_moving = true

func _on_y_axis_button_down() -> void:
	y_axis_moving = true

func _on_both_button_down() -> void:
	both_moving = true

func _on_rotation_button_down() -> void:
	rotating = true

func _on_x_axis_button_up() -> void:
	x_axis_moving = false

func _on_y_axis_button_up() -> void:
	y_axis_moving = false

func _on_both_button_up() -> void:
	both_moving = false

func _on_rotation_button_up() -> void:
	rotating = false
