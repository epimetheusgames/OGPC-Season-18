# Coded by Xavier
extends Entity

@onready var area = $"Area2D"
@onready var diver = $"../Diver"
@onready var submarine_movement = $"SubmarineMovement"

func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		if diver.get_state() == "IN_SUBMARINE": 
			get_parent().get_node("Diver").set_state("DRIVING_SUBMARINE")
			diver.position = position
			diver.velocity = Vector2.ZERO
		elif diver.get_state() == "DRIVING_SUBMARINE":
			get_parent().get_node("Diver").set_state("IN_SUBMARINE")
	print(diver.get_state())
	velocity = submarine_movement.get_velocity()
	print(velocity)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Diver:
		get_parent().get_node("Diver").set_state("IN_SUBMARINE")


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Diver:
		get_parent().get_node("Diver").set_state("SWIMMING")
