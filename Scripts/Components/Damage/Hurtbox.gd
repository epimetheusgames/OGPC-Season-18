## Takes damage from AttackBox
# Owned by: kaitaobenson

class_name Hurtbox
extends Area2D

@export var hurt_by_enemy: bool = false
@export var hurt_by_player: bool = false

@export var max_health: float = 100.0
var health: float = max_health

@export var is_invincible: bool = false


# Signals when the hurtbox takes damage
signal damaged(damage_amount: float)

# Signals when the hurtbox heals
signal healed(heal_amount: float)

# Signals when the health is at 0
signal died()


func _ready() -> void:
	var collision: CollisionShape2D = get_child(0)
	collision.debug_color = Color.GREEN
	collision.debug_color.a = 0.3

func can_take_damage(attackbox: Attackbox) -> bool:
	return (
		(attackbox.attacker_type == Attackbox.AttackerType.ENEMY && hurt_by_enemy) ||
		(attackbox.attacker_type == Attackbox.AttackerType.PLAYER && hurt_by_player) ||
		(attackbox.attacker_type == Attackbox.AttackerType.OTHER)
		) && (!is_invincible)

func damage(damage_amount: float) -> void:
	if is_invincible:
		return
	
	var new_health = clamp(health - damage_amount, 0, max_health)
	emit_signal("damaged", abs(health - new_health))
	health = new_health
	
	if health == 0:
		emit_signal("died")

func heal(heal_amount: float) -> void:
	var new_health = clamp(health + heal_amount, 0, max_health)
	emit_signal("healed", abs(health - new_health))
	health = new_health
