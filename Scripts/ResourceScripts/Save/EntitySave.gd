extends Resource
class_name EntitySave


@export var position := Vector2.ZERO
@export var velocity := Vector2.ZERO

func debug() -> void:
	print("DEBUG: EntitySave: Position: " + str(position))
	print("DEBUG: EntitySave: Velocity: " + str(position))
