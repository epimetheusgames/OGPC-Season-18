## These don't all have to affect the bullet directly
## Might be useful for weapon stats
# Owned by: kaitaobenson

class_name BaseBullet
extends Area2D

@export var speed: float = 0.0
@export var size: float = 0.0
@export var damage: float = 0.0

var velocity: Vector2

func _ready() -> void:
	top_level = true

func _physics_process(delta: float) -> void:
	position += velocity * delta

func fire(angle: float) -> void:
	pass  # Override
