## Chase state for Arrowfish
# Owned by: kaibenson

extends State

@export var aim_state: State
@export var escape_state: State
@export var wander_state: State

var chase_speed: float = 10.0

func enter() -> void:
	pass

func exit() -> void:
	pass


func process_frame(delta: float) -> State:
	return null

func process_physics(delta: float) -> State:
	var diver_pos: Vector2 = enemy.get_diver_pos()
	
	enemy.nav_agent.target_position = diver_pos
	
	var next_path_pos = enemy.nav_agent.get_next_path_position()
	enemy.accelerate_towards(next_path_pos, chase_speed)
	
	if !enemy.enemy_fov.can_see_point(diver_pos):
		return wander_state
	if enemy.global_position.distance_squared_to(diver_pos) < 100 ** 2:
		return escape_state
	if enemy.global_position.distance_squared_to(diver_pos) < 1000 ** 2:
		return aim_state
	
	return null
