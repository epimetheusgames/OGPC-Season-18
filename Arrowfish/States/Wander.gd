## Wander state for the Arrowfish
# Owned by: kaibenson
extends State

var enemy: Enemy

@export var aim_state: State

var wander_anchor: Vector2
var wander_radius: float = 500.0
var wander_speed: float = 4.0
var wander_timer: Timer = Timer.new()
var wander_target_pos: Vector2

func init() -> void:
	assert(parent is Enemy, "This state must have Enemy parent")
	enemy = parent # Syntax sugar
	
	wander_anchor = parent.global_position
	
	add_child(wander_timer)
	
	wander_timer.wait_time = 0.5
	wander_timer.one_shot = false
	wander_timer.start()
	wander_timer.timeout.connect(_update_wander_position)

# Wander position updates every x seconds
func _update_wander_position() -> void:
	wander_target_pos = get_random_point_in_circle(wander_anchor, wander_radius)

func enter() -> void:
	pass

func exit() -> void:
	pass

func process_input(event: InputEvent) -> State:
	return null

func process_frame(delta: float) -> State:
	return null

func process_physics(delta: float) -> State:
	enemy.nav_agent.target_position = wander_target_pos
	var next_path_pos = enemy.nav_agent.get_next_path_position()
	
	parent.accelerate_towards(next_path_pos, wander_speed, delta)
	
	var diver_pos: Vector2 = Global.player.global_position
	if enemy.enemy_fov.can_see_point(diver_pos):
		return aim_state
	
	return null


static func get_random_point_in_circle(circle_pos: Vector2, circle_radius: float) -> Vector2:
	while true:
		var rand_pos: Vector2 = Vector2(
			randi_range(circle_pos.x - circle_radius, circle_pos.x + circle_radius),
			randi_range(circle_pos.y - circle_radius, circle_pos.y + circle_radius)
		)
		
		if circle_pos.distance_to(rand_pos) <= circle_radius:
			return rand_pos
	
	return Vector2.ZERO # Shouldn't happen
