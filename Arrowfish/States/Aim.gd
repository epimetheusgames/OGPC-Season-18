## Aim state for the Arrowfish
# Owned by: kaibenson
extends State

@export var dash_state: State
@export var chase_state: State

var enemy: Enemy

var aim_timer: float = 0.0

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
	
	enemy.rotation = lerp_angle(
		enemy.rotation,
		enemy.global_position.angle_to_point(diver_pos),
		4.0 * delta
	)
	
	aim_timer += delta
	
	if aim_timer >= 5.0:
		aim_timer = 0.0
		return dash_state
	
	return null
