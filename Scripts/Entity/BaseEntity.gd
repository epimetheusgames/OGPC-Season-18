# Base class for all entities
class_name Entity
extends CharacterBody2D


@export var _has_physics := false

func _process(delta: float) -> void:
	if _has_physics:
		move_and_slide()

# Setters and getters

## Set kinematic physics to true for the entity.
func enable_physics() -> void:
	_has_physics = true
	
## Disable kinematic physics for the entity.
func disable_physics() -> void:
	_has_physics = false
