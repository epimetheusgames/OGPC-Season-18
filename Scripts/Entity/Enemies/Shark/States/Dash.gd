## Dash state for Shark
# Owned by: kaibenson
extends State

@export var chase_state: State

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
	
	if has_reached_pos(target_pos):
		return chase_state
	
	enemy.spring_towards(target_pos, 1, 0.1, delta)
	
	return null

func has_reached_pos(pos: Vector2) -> bool:
	var distance: float = enemy.global_position.distance_to(pos)
	if distance < 150:
		return true
	else:
		return false
