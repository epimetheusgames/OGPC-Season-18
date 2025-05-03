class_name DiverFlashlight
extends Node2D

@onready var diver: Diver = get_parent()
@onready var flashlight: PointLight2D = $"Flashlight"
@onready var body_light: PointLight2D = $"BodyLight"

var lights_on: bool = true

func _process(delta: float) -> void:
	if Global.is_multiplayer && diver.has_multiplayer_sync && !diver._is_node_owner():
		return
	
	if diver.get_state() == Diver.DiverState.SWIMMING:
		if lights_on:
			turn_lights_on()
		else:
			turn_lights_off()
		
		if Input.is_action_just_pressed("flashlight_toggle"):
			lights_on = !lights_on
	else:
		turn_lights_off()
	
	var angle_to_mouse := flashlight.global_position.angle_to_point(get_global_mouse_position()) + PI/2
	flashlight.global_rotation = Util.better_angle_lerp(flashlight.global_rotation, angle_to_mouse, 0.5, delta)
	body_light.global_rotation = 0.0
	
	if Global.godot_steam_abstraction:
		Global.godot_steam_abstraction.sync_var(flashlight, "visible")
		Global.godot_steam_abstraction.sync_var(body_light, "visible")
		Global.godot_steam_abstraction.sync_var(flashlight, "global_rotation")

func turn_lights_on() -> void:
	flashlight.visible = true
	body_light.visible = true

func turn_lights_off() -> void:
	flashlight.visible = false
	body_light.visible = false
