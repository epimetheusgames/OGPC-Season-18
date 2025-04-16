## Dash state for Arrowfish
# Owned by: kaibenson
extends State

@export var chase_state: State

# Time to wait before dashing
var pause_time: float = 0.5
var pause_timer: float = 0.0

# Dash to this pos
var target_pos: Vector2


func enter() -> void:
	target_pos = enemy.get_diver_pos()

func exit() -> void:
	pass

func process_frame(delta: float) -> State:
	return null

func process_physics(delta: float) -> State:
	if !enemy.enemy_fov.can_see_point(target_pos):
		return chase_state
	
	pause_timer += delta
	if pause_timer < pause_timer:
		return null
	
	if has_reached_pos(target_pos):
		return chase_state
	
	enemy.spring_towards(target_pos, 3, 0.1, delta)
	
	return null

func has_reached_pos(pos: Vector2) -> bool:
	var distance: float = enemy.global_position.distance_to(pos)
	#print("DISTANCE: " + str(distance))
	if distance < 150:
		return true
	else:
		return false
