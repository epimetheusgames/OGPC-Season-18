## Takes damage from AttackBox
# Owned by: kaitaobenson

class_name Hurtbox
extends Area2D

# For coloring when damaged
@export var entity: Node2D

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
	
	var new_health = clamp(health - damage_amount, 0, max_health)
	health = new_health
	
	flash_red()
	knockback(by.global_position, by.knockback_force)
	
	damaged.emit(abs(health - new_health), by)
	
	if health == 0:
		died.emit()
		if get_parent() is Enemy:
			get_parent()._die()

func heal(heal_amount: float) -> void:
	var new_health = clamp(health + heal_amount, 0, max_health)
	health = new_health
	
	healed.emit(abs(health - new_health))

func flash_red() -> void:
	if entity:
		entity.modulate = Color(1, 0, 0)
		await get_tree().create_timer(0.6).timeout
		entity.modulate = Color(1, 1, 1)

func knockback(from_position: Vector2, force: float) -> void:
	if force == 0:
		return
	
	if entity is Diver:
		var q = (entity.global_position - from_position).normalized() * force
		entity.diver_movement.knockback(q)
