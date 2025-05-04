extends State

@export var chase_state: State

var wander_anchor: Vector2
var wander_radius := 900.0
var wander_speed := 2.0

@onready var wander_timer: Timer = $WanderTimer

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
	wander_target_pos = wander_anchor + Util.random_vector(Global.rng, wander_radius)

func process_physics(delta: float) -> State:
	enemy.nav_agent.target_position = wander_target_pos
	var next_path_pos = enemy.nav_agent.get_next_path_position()
	
	enemy.drift_towards(next_path_pos, wander_speed, 0.1)
	
	var diver_pos: Vector2 = enemy.get_diver_pos()
	
	if enemy.enemy_fov.can_see_point(diver_pos):
		return chase_state
	
	return null
	
