## For state machine
# Owned by: kaibenson

extends State

@export var wander_state: State

var escape_toggle: bool = true
var escape_angle_variation: float = 20.0

var escape_timer: Timer = Timer.new()

var escape_target_pos: Vector2


func init() -> void:
	add_child(escape_timer)
	
	escape_timer.one_shot = false
	escape_timer.wait_time = 0.5
	
	escape_timer.connect("timeout", _update_escape_position)
	escape_timer.start()

func enter() -> void:
	pass

func exit() -> void:
	pass


func process_frame(delta: float) -> State:
	return null


func _update_escape_position() -> void:
	var diver_pos: Vector2 = enemy.get_diver_pos()
	
	var escape_angle: float = (enemy.global_position - diver_pos).angle()
	
	if escape_toggle:
		escape_toggle = false
		escape_angle += deg_to_rad(escape_angle_variation)
	else:
		escape_toggle = true
		escape_angle -= deg_to_rad(escape_angle_variation)
	
	escape_target_pos = enemy.global_position + Util.angle_to_vector_radians(escape_angle, 1000)


func process_physics(delta: float) -> State:
	var diver_pos: Vector2 = enemy.get_diver_pos()
	
	enemy.nav_agent.target_position = escape_target_pos
	var escape_pos = enemy.nav_agent.get_next_path_position()
	
	enemy.move_towards(escape_pos, 500)
	
	if enemy.global_position.distance_to(diver_pos) > 800:
		return wander_state
	
	return null
