## Creates a one-shot attack that will deal damage to each 
## hurtbox entered exactly once when attack() is called
# Owned by: kaitaobenson

class_name OneShotAttack
extends Attackbox

func _ready() -> void:
	super()

func _process(delta: float) -> void:
	if enabled:
		enabled = false
