# Coded by Xavier
class_name Submarine
extends Entity

@onready var diver = Global.player
@onready var submarine_movement = $"SubmarineMovement"
@onready var module_container : ModuleLoader = $"Modules"

var control_module = preload("res://Scenes/TSCN/Entities/Submarine/SubmarineControlModule.tscn")

func _ready() -> void:
	if !Global.submarine:
		Global.submarine = self
	 
	var custom_sub : CustomSubmarineResource = CustomSubmarineResource.new()
	custom_sub.modules.append(load("res://Scenes/Resource/custom_sub2.tres"))
	#custom_sub.modules.append(load("res://Scenes/Resource/custom_sub2.tres"))
	module_container.load_sub(custom_sub)
	

func _physics_process(_delta: float) -> void:
	move_and_slide()
	velocity = submarine_movement.get_velocity()
	if diver.get_state() == Util.DiverState.DRIVING_SUBMARINE:
		diver.global_transform = $"Modules/SubmarineControlModule".global_transform

func _on_submarine_area_area_entered(area: Area2D) -> void:
	if area.get_parent() is Diver:
		Global.player.set_state(Util.DiverState.IN_SUBMARINE)

func _on_submarine_area_area_exited(area: Area2D) -> void:
	if area.get_parent() is Diver:
		Global.player.set_state(Util.DiverState.SWIMMING)
