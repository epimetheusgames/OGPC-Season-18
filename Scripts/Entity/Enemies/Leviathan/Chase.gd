extends State

@export var wander_state: State

func init() -> void:
	pass

func enter() -> void:
	pass

func exit() -> void:
	pass

func process_input(event: InputEvent) -> State:
	return null

func process_frame(delta: float) -> State:
	return null

func process_physics(delta: float) -> State:
	var leviathan: Leviathan = enemy
	
	var diver_pos: Vector2 = leviathan.get_diver_pos()
	
	if leviathan.enemy_fov.can_see_point(diver_pos):
		leviathan.move_towards(diver_pos, 500)
		return null
	else:
		return wander_state
