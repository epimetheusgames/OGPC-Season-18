## Wander state for the Shark
# Owned by: kaibenson
extends State

@export var chase_state: State

var enemy: Enemy

var wander_anchor: Vector2
var wander_radius: float = 900.0
var wander_speed: float = 6

# Generates a new wander_target_pos periodically
@onready var wander_timer: Timer = $"WanderTimer"
var wait_time: float = 2.0

var wander_target_pos: Vector2

func init() -> void:
	assert(parent is Enemy, "This state must have Enemy parent")
	enemy = parent 
	
	wander_anchor = parent.global_position
	wander_timer.timeout.connect(_update_wander_position)

func enter() -> void:
	_update_wander_position()
	wander_timer.start()

func exit() -> void:
	wander_timer.stop()

func process_frame(delta: float) -> State:
	return null

func _update_wander_position() -> void:
	wander_target_pos = Util.get_random_point_in_circle(wander_anchor, wander_radius)
	wander_timer.wait_time = randf_range(wait_time - 1, wait_time + 1)

func process_physics(delta: float) -> State:
	enemy.nav_agent.target_position = wander_target_pos
	var next_path_pos = enemy.nav_agent.get_next_path_position()
	
	parent.accelerate_towards(next_path_pos, wander_speed, delta)
	
	var diver_pos: Vector2 = enemy.get_diver_pos()
	
	if enemy.enemy_fov.can_see_point(diver_pos):
		return chase_state
	
	return null
