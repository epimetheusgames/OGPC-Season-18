## SPIN state for the jellyfish: spins tentacles in a full curcle
extends State

@export var wander_state: State
@export var boost_state: State

const spin_factor: float = 0.01

var target_angle: float
var rotated_angle: float

func init() -> void:
	pass

func enter() -> void:
	target_angle = enemy.rotation_degrees + 460
	rotated_angle = enemy.rotation_degrees

func process_physics(delta: float) -> State:
	rotated_angle = rotated_angle + (target_angle - rotated_angle) * spin_factor
	enemy.rotation_degrees = rotated_angle
	
	if rotated_angle > target_angle - 10:
		var diver_pos: Vector2 = enemy.get_diver_pos()
		
		if enemy.enemy_fov.can_see_point(diver_pos):
			return boost_state
		else:
			return wander_state
	
	return null
