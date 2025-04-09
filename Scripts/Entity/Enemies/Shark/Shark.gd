class_name Shark
extends Enemy

func _ready() -> void:
	state_machine.init(self)

func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)
	move_and_slide()
