extends Resource
class_name EntitySave


@export var position := Vector2.ZERO
@export var velocity := Vector2.ZERO

func debug() -> void:
	Global.print_debug("DEBUG: EntitySave: Position: " + str(position))
	Global.print_debug("DEBUG: EntitySave: Velocity: " + str(velocity))
