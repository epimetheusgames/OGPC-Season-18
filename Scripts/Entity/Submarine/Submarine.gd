# Coded by Xavier
class_name Submarine
extends Entity

@onready var submarine_movement = $"SubmarineMovement"
@onready var module_container : ModuleLoader = $"Modules"

func _ready() -> void:
	if !Global.submarine:
		Global.submarine = self
	 
	var custom_sub : CustomSubmarineResource = load("res://Scenes/Resource/TestSubmarines/custom_sub_gen.tres")
	module_container.load_sub(custom_sub)
	
	if Global.godot_steam_abstraction && Global.is_multiplayer && _is_node_owner():
		var remote_sub := module_container.construct_remote_sub(custom_sub)
		Global.godot_steam_abstraction.run_remote_function(module_container, "load_sub_remote", [remote_sub])

func _physics_process(_delta: float) -> void:
	move_and_slide()
	velocity = submarine_movement.get_velocity()
	if Global.player.get_state() == Util.DiverState.DRIVING_SUBMARINE:
		Global.player.global_transform = $"Modules/SubmarineControlModule".global_transform
		
	# TODO: Instead of disabled, make them collide with only the player.
	if Global.player.get_state() == Util.DiverState.IN_SUBMARINE || Global.player.get_state() == Util.DiverState.DRIVING_SUBMARINE:
		for child in get_children():
			if child is CollisionShape2D:
				child.disabled = true
	else:
		for child in get_children():
			if child is CollisionShape2D:
				child.disabled = false

func _on_submarine_area_area_entered(area: Area2D) -> void:
	if area.get_parent() is Diver:
		Global.player.set_state(Util.DiverState.IN_SUBMARINE)

func _on_submarine_area_area_exited(area: Area2D) -> void:
	if area.get_parent() is Diver:
		Global.player.set_state(Util.DiverState.SWIMMING)
