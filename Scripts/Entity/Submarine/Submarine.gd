# Coded by Xavier
extends Entity

@onready var diver = Global.player
@onready var submarine_movement = $"SubmarineMovement"

var control = preload("res://Scenes/TSCN/Entities/Submarine/SubmarineControlModule.tscn")

func _ready() -> void:
	if !Global.submarine:
		Global.submarine = self
	
	var module = control.instantiate()
	get_node("Modules").add_child(module)

func _physics_process(_delta: float) -> void:
	if diver.get_state() == Util.DiverState.DRIVING_SUBMARINE:
		diver.global_transform = global_transform
		velocity = submarine_movement.get_velocity()

func _on_submarine_area_area_entered(area: Area2D) -> void:
	if area.get_parent() is Diver:
		Global.player.set_state(Util.DiverState.IN_SUBMARINE)

func _on_submarine_area_area_exited(area: Area2D) -> void:
	if area.get_parent() is Diver:
		Global.player.set_state(Util.DiverState.SWIMMING)
