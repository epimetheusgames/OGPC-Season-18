## Creates a one-shot attack that will deal damage to 
## each new hurtbox encountered exactly once.
# Owned by: kaitaobenson

class_name OneShotAttack
extends Attackbox

var damaged_hurtboxes: Array[Hurtbox] = []

func detect_and_damage_hurtboxes() -> void:
	var areas: Array[Area2D] = get_overlapping_areas()
	
	for area in areas:
		if !area is Hurtbox:
			continue
		if damaged_hurtboxes.has(area):
			continue
		
		var hurtbox: Hurtbox = area
		
		if !hurtbox.can_take_damage(self):
			continue
		
		damage_hurtbox(hurtbox)
		damaged_hurtboxes.append(hurtbox)
