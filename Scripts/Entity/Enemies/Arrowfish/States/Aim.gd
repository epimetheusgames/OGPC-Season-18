## Aim state for the Arrowfish
# Owned by: kaibenson
extends State

@export var dash_state: State
@export var chase_state: State

var wait_time: float = 2.0
var aim_timer: float = 0.0


func enter() -> void:
	pass

func exit() -> void:
	pass

func process_frame(delta: float) -> State:
	return null

func process_physics(delta: float) -> State:
	var diver_pos: Vector2 = enemy.get_diver_pos()
	
	enemy.rotation = lerp_angle(
		enemy.rotation,
		enemy.global_position.angle_to_point(diver_pos),
		4.0 * delta
	)
	enemy.velocity *= 0.6
	
	aim_timer += delta
	
	if aim_timer >= wait_time:
		aim_timer = 0.0
		return dash_state
	
	if !enemy.enemy_fov.can_see_point(diver_pos):
		return chase_state
	
	return null
