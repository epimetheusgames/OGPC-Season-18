extends State

var enemy: Enemy

@export var escape_state: State
@export var wander_state: State

func init() -> void:
	assert(parent is Enemy, "This state must have Enemy parent")
	enemy = parent

func enter() -> void:
	pass

func exit() -> void:
	pass

func process_input(event: InputEvent) -> State:
	return null

func process_frame(delta: float) -> State:
	return null

func process_physics(delta: float) -> State:
	var diver_pos: Vector2 = enemy.get_diver_pos()
	
	enemy.nav_agent.target_position = diver_pos
	
	var next_path_pos = enemy.nav_agent.get_next_path_position()
	enemy.accelerate_towards(next_path_pos, 5, delta)
	
	if enemy.hurtbox.health < 30:
		return escape_state
	elif !enemy.enemy_fov.can_see_point(diver_pos):
		return wander_state
	
	return null
