## Attacks continuously, will delay after hitting a hurtbox.
# Owned by: kaitaobenson

class_name ContinuousAttack
extends Attackbox

@export var delay_time: float = 1.0

var damaged_hurtboxes: Array[Hurtbox] = []
var is_delayed: bool = false

var delay_timer: Timer

func _ready() -> void:
	delay_timer = Timer.new()
	delay_timer.wait_time = delay_time
	delay_timer.one_shot = true
	delay_timer.connect("timeout", _on_timer_timeout)
	add_child(delay_timer)

func _process(delta: float) -> void:
	if is_delayed:
		return
	
	var areas: Array[Area2D] = get_overlapping_areas()
	var hit_hurtbox: bool = false
	
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
		hit_hurtbox = true
	
	if hit_hurtbox:
		start_delay()

func start_delay() -> void:
	if !is_delayed:
		is_delayed = true
		delay_timer.start()

func _on_timer_timeout() -> void:
	is_delayed = false
	damaged_hurtboxes.clear()
