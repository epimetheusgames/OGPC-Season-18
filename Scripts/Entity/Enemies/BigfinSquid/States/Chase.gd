extends State


@export var wander_state: State

var chase_speed: float = 3.0

func enter() -> void: pass
func exit() -> void: pass

func process_frame(delta: float) -> State:
	return null

func process_physics(delta: float) -> State:
	var diver_pos: Vector2 = enemy.get_diver_pos()
	
	enemy.nav_agent.target_position = diver_pos
	
	var next_path_pos = enemy.nav_agent.get_next_path_position()
	enemy.drift_towards(next_path_pos, chase_speed, 0.1)
	
	if !enemy.enemy_fov.can_see_point(diver_pos):
		return wander_state
	
	return null
