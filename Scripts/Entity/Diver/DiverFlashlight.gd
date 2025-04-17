class_name DiverFlashlight
extends Node2D

@onready var diver: Diver = get_parent()
@onready var flashlight: PointLight2D = $"Flashlight"
@onready var body_light: PointLight2D = $"BodyLight"

# TODO: Light Area does nothing yet

func _process(delta: float) -> void:
	if Global.is_multiplayer && diver.has_multiplayer_sync && !diver._is_node_owner():
		return
	
	if diver.get_state() != Util.DiverState.SWIMMING:
		flashlight.visible = false
		body_light.visible = false
	else:
		flashlight.visible = true
		body_light.visible = true
	
	var angle_to_mouse := flashlight.global_position.angle_to_point(get_global_mouse_position()) + PI/2
	flashlight.global_rotation = Util.better_angle_lerp(flashlight.global_rotation, angle_to_mouse, 0.5, delta)
	
	if Global.godot_steam_abstraction:
		Global.godot_steam_abstraction.sync_var(flashlight, "visible")
		Global.godot_steam_abstraction.sync_var(body_light, "visible")
		Global.godot_steam_abstraction.sync_var(flashlight, "global_rotation")
