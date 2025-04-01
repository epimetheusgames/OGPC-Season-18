class_name DiverFlashlight
extends Node2D

@onready var diver: Diver = get_parent()

@onready var flash_light: PointLight2D = $"FlashLight"
@onready var body_light: PointLight2D = $"BodyLight"

var query_params := PhysicsShapeQueryParameters2D.new()

func _ready() -> void:
	flash_light.top_level = true
	body_light.top_level = true
	
	query_params.exclude = [(diver.get_rid())]

func _process(delta: float) -> void:
	if Global.is_multiplayer && diver.has_multiplayer_sync && !diver._is_node_owner():
		return
	
	if diver.get_state() == Util.DiverState.IN_GRAVITY_AREA:
		flash_light.visible = false
		body_light.visible = false
	else:
		flash_light.visible = true
		body_light.visible = false
	
	var mouse_pos: Vector2 = get_global_mouse_position()
	var diver_pos: Vector2 = diver.global_position
	var head_pos: Vector2 = diver.diver_animation.get_head_position()
	
	var fl_pos: Vector2 = head_pos
	var fl_rot: float = Util.better_angle_lerp(flash_light.global_rotation, head_pos.angle_to_point(mouse_pos) + PI/2, 0.3, delta)
	
	if Global.godot_steam_abstraction:
		Global.godot_steam_abstraction.sync_var(flash_light, "visible")
		Global.godot_steam_abstraction.sync_var(body_light, "visible")
		Global.godot_steam_abstraction.run_remote_function(self, "set_flash_light_pos", [fl_pos])
		Global.godot_steam_abstraction.run_remote_function(self, "set_flash_light_rot", [fl_rot])
		Global.godot_steam_abstraction.run_remote_function(self, "set_body_light_pos", [diver_pos])
	
	set_flash_light_pos(fl_pos)
	set_flash_light_rot(fl_rot)
	
	set_body_light_pos(diver_pos)

func set_flash_light_pos(pos: Vector2) -> void:
	flash_light.global_position = pos

func set_flash_light_rot(rot: float) -> void:
	flash_light.global_rotation = rot

func set_body_light_pos(pos: Vector2) -> void:
	body_light.global_position = pos
