## Abstract class for dealing damage to Hurtbox
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

# Signals when it hits a hurtbox
signal hurtbox_hit(hurtbox, Hurtbox)

# Signals when it damages a hurtbox
signal damage_dealt(hurtbox: Hurtbox, damage_amount: float)

# Signals when a hurtbox damaged reaches 0 health
signal killed()

func _ready() -> void:
	var collision: CollisionShape2D = get_child(0)
	collision.debug_color = Color.RED
	collision.debug_color.a = 0.3

func _process(delta: float) -> void:
	var areas: Array[Area2D] = get_overlapping_areas()
	
	for area in areas:
		if area is Hurtbox:
			var hurtbox: Hurtbox = area
			emit_signal("hurtbox_hit", hurtbox)

func damage_hurtbox(hurtbox: Hurtbox) -> void:
	if hurtbox.can_take_damage(self):
		
		hurtbox.damage(damage_amount)
		emit_signal("damage_dealt", damage_amount)
		
		if hurtbox.health - damage_amount <= 0:
			emit_signal("killed")
