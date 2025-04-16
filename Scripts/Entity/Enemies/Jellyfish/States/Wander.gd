## Jellyfish wander
extends State

@export var aim_state: State

var wander_anchor: Vector2
var wander_radius: float = 1000.0
var wander_speed: float = 100.0

# Generates a new wander_target_pos periodically
@onready var wander_timer: Timer = $"WanderTimer"
var wait_time: float = 10.0

var wander_target_pos: Vector2

func init() -> void:
	wander_anchor = enemy.global_position
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
	
	enemy = enemy as Jellyfish
	enemy.boost(wander_speed, 5, next_path_pos)
	print("SLDSFSDFSDF: " + str(next_path_pos))
	
	var diver_pos: Vector2 = enemy.get_diver_pos()
	
	
	return null
