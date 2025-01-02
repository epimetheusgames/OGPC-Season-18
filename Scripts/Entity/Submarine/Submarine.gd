# Coded by Xavier
extends Entity

@onready var diver = Global.player
@onready var submarine_movement = $"SubmarineMovement"
@onready var seat = $"SeatPos"

var in_driving_area : bool = false

func _ready() -> void:
	if !Global.submarine:
		Global.submarine = self

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and in_driving_area:
		if diver.get_state() == Util.DiverState.IN_SUBMARINE: 
			diver.set_state(Util.DiverState.DRIVING_SUBMARINE)
		elif diver.get_state() == Util.DiverState.DRIVING_SUBMARINE:
			diver.set_state(Util.DiverState.IN_SUBMARINE)
	print(diver.get_state())
	print(velocity)
	if diver.get_state() == Util.DiverState.DRIVING_SUBMARINE:
		diver.global_transform = seat.global_transform
		velocity = submarine_movement.get_velocity()

func _on_drive_area_area_entered(area: Area2D) -> void:
	if area.get_parent() is Diver:
		in_driving_area = true

func _on_drive_area_area_exited(area: Area2D) -> void:
	if area.get_parent() is Diver:
		in_driving_area = false

func _on_submarine_area_area_entered(area: Area2D) -> void:
	if area.get_parent() is Diver:
		Global.player.set_state(Util.DiverState.IN_SUBMARINE)


func _on_submarine_area_area_exited(area: Area2D) -> void:
	if area.get_parent() is Diver:
		Global.player.set_state(Util.DiverState.SWIMMING)
