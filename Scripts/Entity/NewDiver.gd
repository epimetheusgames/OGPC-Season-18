extends CharacterBody2D

@onready var diver_movement: DiverMovement = $"Movement"

@onready var arrow: Node2D = $"Arrow"

var current_angle: float = 0.0

func _ready() -> void:
	arrow = Util.safeguard_null(arrow, "Node2D")
	diver_movement = Util.safeguard_null(diver_movement, "DiverMovement")


func _physics_process(delta: float):
	velocity = diver_movement.get_velocity()
	arrow.global_rotation = diver_movement.get_current_angle()
	move_and_slide()
