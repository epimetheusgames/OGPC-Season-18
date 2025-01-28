## Attacks continuously, will delay after hitting a hurtbox.
# Owned by: kaitaobenson

class_name ContinuousAttack
extends Attackbox

@export var delay_time: float = 1.0

var damaged_hurtboxes: Array[Hurtbox] = []

func _process(delta: float) -> void:
	var areas: Array[Area2D] = get_overlapping_areas()
	
	for area in areas:
		if !area is Hurtbox:
			return
		if damaged_hurtboxes.has(area):
			return
		
		var hurtbox: Hurtbox = area
		damage_hurtbox(hurtbox)
		damaged_hurtboxes.append(hurtbox)
	
	if !areas.is_empty():
		await get_tree().create_timer(delay_time).timeout
