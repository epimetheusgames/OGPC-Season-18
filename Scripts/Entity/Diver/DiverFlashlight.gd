class_name DiverFlashlight
extends Node2D

@onready var diver: Diver = get_parent()

@onready var flash_light: PointLight2D = $"FlashLight"
@onready var body_light: PointLight2D = $"BodyLight"

func _ready() -> void:
	flash_light.top_level = true
	body_light.top_level = true

func _process(_delta: float) -> void:
	if Global.is_multiplayer && diver.has_multiplayer_sync && !diver._is_node_owner():
		return
	
	var mouse_pos: Vector2 = get_global_mouse_position()
	var head_pos: Vector2 = diver.diver_animation.get_head_position()
	var diver_pos: Vector2 = diver.global_position
	
	var flash_light_rot: float = head_pos.angle_to_point(mouse_pos) + PI/2
	
	if Global.godot_steam_abstraction:
		Global.godot_steam_abstraction.run_remote_function(self, "set_flash_light_pos", [head_pos])
		Global.godot_steam_abstraction.run_remote_function(self, "set_flash_light_rot", [flash_light_rot])
		
		Global.godot_steam_abstraction.run_remote_function(self, "set_body_light_pos", [diver_pos])
	
	set_flash_light_pos(head_pos)
	set_flash_light_rot(flash_light_rot)
	
	set_body_light_pos(diver_pos)

func set_flash_light_pos(pos: Vector2) -> void:
	flash_light.global_position = pos
func set_flash_light_rot(rot: float) -> void:
	flash_light.global_rotation = rot

func set_body_light_pos(pos: Vector2) -> void:
	body_light.global_position = pos
