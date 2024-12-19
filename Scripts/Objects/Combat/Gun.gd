# Base class for guns
## Owned by: kaitaobenson

class_name Gun
extends Weapon

var hand1_pos: Vector2 = Vector2.ZERO
var hand2_pos: Vector2 = Vector2.ZERO

@export var animation_node: AnimatedSprite2D
@export var bullet_scene: PackedScene

var enabled: bool = false

func attack() -> void:
	pass  # Override

func get_gun_position() -> Vector2:
	return Vector2.ZERO  # Override

func get_gun_rotation() -> float:
	return 0.0  # Override


func set_hand1_pos(pos: Vector2) -> void:
	hand1_pos = pos
func set_hand2_pos(pos: Vector2) -> void:
	hand2_pos = pos
