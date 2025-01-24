## Deals damage to HurtBox
# Owned by: kaitaobenson

class_name Attackbox
extends Area2D

enum AttackerType {
	ENEMY,
	PLAYER,
	OTHER,
}

@export var attacker_type: AttackerType = AttackerType.OTHER
@export var damage_amount: float = 1.0

var is_attacking: bool = false

signal damage_delt(amount: float)
signal killed()

func _on_body_entered(body: Node):
	if is_attacking && body is Hurtbox:
		if can_damage(body):
			var damage_dealt = body.take_damage(damage_amount)
			damage_delt.emit(damage_amount)
			if body.health <= 0:
				killed.emit()

func can_damage(hurtbox: Hurtbox) -> bool:
	return (
		(attacker_type == AttackerType.ENEMY && hurtbox.hurt_by_enemy) ||
		(attacker_type == AttackerType.PLAYER && hurtbox.hurt_by_player)
	)
