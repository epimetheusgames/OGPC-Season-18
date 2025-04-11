# Coded by Xavier
class_name Submarine
extends Entity

@onready var submarine_movement = $"SubmarineMovement"

func _ready() -> void:
	if !Global.submarine:
		Global.submarine = self

func _physics_process(_delta: float) -> void:
	move_and_slide()
	velocity = submarine_movement.get_velocity()
	if Global.player.get_state() == Util.DiverState.DRIVING_SUBMARINE:
		Global.player.global_transform = global_transform

func _on_submarine_area_area_entered(area: Area2D) -> void:
	if area.get_parent() is Diver:
		Global.player.set_state(Util.DiverState.IN_SUBMARINE)

func _on_submarine_area_area_exited(area: Area2D) -> void:
	if area.get_parent() is Diver:
		Global.player.set_state(Util.DiverState.SWIMMING)
