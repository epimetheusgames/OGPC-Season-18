## Dash state for Arrowfish
# Owned by: kaibenson
extends State

var enemy: Enemy

@export var chase_state: State

var dash_timer: float = 0.0


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
	enemy.spring_towards(diver_pos, 10, 0.1, delta)
	
	dash_timer += delta
	if dash_timer >= 1.0:
		dash_timer = 0.0
		return chase_state
	
	return null
