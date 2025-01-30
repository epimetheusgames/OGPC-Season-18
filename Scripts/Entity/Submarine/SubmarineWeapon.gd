# Coded by Xavier
## Base class for submarine weapons

class_name SubmarineWeapon 
extends Node2D

# Subclass dependent variables
var rotation_range : float
var projectile_path : String

var max_rotation : float = rotation + rotation_range
var min_rotation : float = rotation - rotation_range

var is_being_operated : bool = false

## NOTE: If we end up having a range that goes above 180 (PI) or -180 (-PI) (eg. min = 160, max = 200) then we might have some clamping issues
func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if is_being_operated:
		var mouse_vector_angle = get_mouse_input_vector().angle()
		var target_rot = clamp(mouse_vector_angle, min_rotation, max_rotation)
		rotation = Util.better_angle_lerp(rotation, target_rot, .2, delta)

func get_mouse_input_vector() -> Vector2:
	return (Vector2(DisplayServer.mouse_get_position()) - global_position).normalized()
