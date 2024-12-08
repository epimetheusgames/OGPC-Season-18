# Owned by carsonetb
class_name BaseBullet
extends Area2D


var _velocity := Vector2.ZERO
var _damage := 1.0

func _process(delta: float) -> void:
	position += _velocity * delta * 60

# Setters and getters
func set_damage(new_damage: float) -> void:
	_damage = new_damage
	$AttackBoxComponent.damage = new_damage
	
func get_damage() -> float:
	return _damage

func set_velocity(new_velocity: Vector2) -> void:
	_velocity = new_velocity

func get_velocity() -> Vector2:
	return _velocity
