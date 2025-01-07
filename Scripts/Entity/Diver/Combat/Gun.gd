# Base class for guns
## Owned by: kaitaobenson

class_name Gun
extends Weapon

@export var animation_node: AnimatedSprite2D
@export var bullet_scene: PackedScene

func _process(delta: float) -> void:
	super(delta)

func get_gun_position() -> Vector2:
	return Vector2.ZERO  # Override

func get_gun_rotation() -> float:
	return 0.0  # Override
