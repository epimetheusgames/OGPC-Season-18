## Takes damage from AttackBox
# Owned by: kaitaobenson

class_name Hurtbox
extends Area2D

@export var hurt_by_enemy: bool = false
@export var hurt_by_player: bool = false

@export var max_health: float = 100.0
var health: float = max_health

var is_invincible: bool = false

signal damage_taken(damage_amount: float)
signal died()

func take_damage(amount: float) -> float:
	if is_invincible:
		return 0.0
	health -= amount
	emit_signal("damage_taken", amount)
	if health <= 0:
		health = 0
		emit_signal("died")
	return amount

func heal(amount: float):
	health = min(health + amount, max_health)
