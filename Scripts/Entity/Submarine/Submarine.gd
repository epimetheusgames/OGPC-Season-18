# Coded by Xavier
extends Entity

@onready var diver = Global.player
@onready var submarine_movement = $"SubmarineMovement"

func _ready() -> void:
	pass


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		if diver.get_state() == "IN_SUBMARINE": 
			diver.set_state("DRIVING_SUBMARINE")
			diver.position = position
			diver.velocity = Vector2.ZERO
		elif diver.get_state() == "DRIVING_SUBMARINE":
			diver.set_state("IN_SUBMARINE")
	print(diver.get_state())
	print(velocity)
	if diver.get_state() == "DRIVING_SUBMARINE":
		diver.global_transform = self.global_transform
		velocity = submarine_movement.get_velocity()



func _on_drive_area_area_entered(area: Area2D) -> void:
	if area.get_parent() is Diver:
		Global.player.set_state("IN_SUBMARINE")


func _on_drive_area_area_exited(area: Area2D) -> void:
	if area.get_parent() is Diver:
		Global.player.set_state("SWIMMING")
