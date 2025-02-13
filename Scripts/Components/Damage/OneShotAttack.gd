## Creates a one-shot attack that will deal damage to each 
## hurtbox entered exactly once when attack() is called
# Owned by: kaitaobenson

class_name OneShotAttack
extends Attackbox

@export var is_attacking: bool = false

var damaged_hurtboxes: Array[Hurtbox] = []

func _ready() -> void:
	super()
	connect("hurtbox_hit", _on_hurtbox_hit)

func _on_hurtbox_hit(hurtbox: Hurtbox) -> void:
	if is_attacking:
		if damaged_hurtboxes.has(hurtbox):
			return
		
		damage_hurtbox(hurtbox)
		damaged_hurtboxes.append(hurtbox)

func reset() -> void:
	damaged_hurtboxes.clear()
