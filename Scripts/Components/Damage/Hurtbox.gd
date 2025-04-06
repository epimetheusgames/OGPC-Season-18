## Takes damage from AttackBox
# Owned by: kaitaobenson

class_name Hurtbox
extends Area2D

@export var hurt_by_enemy: bool = false
@export var hurt_by_player: bool = false
@export var max_health: float = 100.0

var health: float = max_health
var is_invincible: bool = false

# Signals when the hurtbox takes damage
signal damaged(damage_amount: float, by: Attackbox)

# Signals when the hurtbox heals
signal healed(heal_amount: float)

# Signals when the health is at 0
signal died()


func _ready() -> void:
	var collision: CollisionShape2D = get_child(0)
	
	assert(collision is CollisionShape2D, "Hurtbox has no collision shape node assigned")
	
	collision.debug_color = Color.GREEN
	collision.debug_color.a = 0.3


func can_take_damage(attackbox: Attackbox) -> bool:
	return (
		(attackbox.attacker_type == Attackbox.AttackerType.ENEMY && hurt_by_enemy) ||
		(attackbox.attacker_type == Attackbox.AttackerType.PLAYER && hurt_by_player) ||
		(attackbox.attacker_type == Attackbox.AttackerType.OTHER)
	) && (!is_invincible)

func damage(damage_amount: float, by: Attackbox) -> void:
	if is_invincible:
		return
	
	Global.print_debug("DEBUG: Hurtbox at path " + str(get_path()) + " was damaged. Amount: " + str(damage_amount))
	
	var new_health = clamp(health - damage_amount, 0, max_health)
	
	health = new_health
	
	damaged.emit(abs(health - new_health), by)
	
	if health == 0:
		died.emit()


func heal(heal_amount: float) -> void:
	var new_health = clamp(health + heal_amount, 0, max_health)
	health = new_health
	
	healed.emit(abs(health - new_health))
