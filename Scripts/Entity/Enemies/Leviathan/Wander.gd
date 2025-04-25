extends State

@export var chase_state: State

var ray_container: Node2D
var ray1: RayCast2D
var ray2: RayCast2D
var ray3: RayCast2D

@onready var noise := FastNoiseLite.new()

var wall_avoid_clockwise: bool = true
var wall_avoid_angle: float = 0.0  # In radians

func init():
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.1
	noise.fractal_octaves = 3
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM

func get_fluctuating_angle(t: float) -> float:
	return deg_to_rad(noise.get_noise_1d(t) * 50.0)  # range ~ -20° to 20°

func enter() -> void:
	ray_container = enemy.get_node("RayCasts")
	ray1 = ray_container.get_node("RayCast2D1")
	ray2 = ray_container.get_node("RayCast2D2")
	ray3 = ray_container.get_node("RayCast2D3")

func exit() -> void:
	pass

func process_physics(delta: float) -> State:
	var leviathan = enemy as Leviathan
	var time = Time.get_ticks_msec() / 1000.0
	
	# Wiggle added on top of the current wall-avoidance direction
	var wiggle_angle = get_fluctuating_angle(time)
	ray_container.rotation = wall_avoid_angle + wiggle_angle
	
	force_update_rays()

	# Avoid wall if colliding
	while ray1.is_colliding() || ray2.is_colliding() || ray3.is_colliding():
		wall_avoid_angle += 0.02 if wall_avoid_clockwise else -0.02
		ray_container.rotation = wall_avoid_angle + get_fluctuating_angle(time)
		force_update_rays()
	
	# Move forward
	leviathan.velocity = Vector2(300, 0).rotated(ray_container.global_rotation)
	
	var diver_pos: Vector2 = enemy.get_diver_pos()
	if leviathan.enemy_fov.can_see_point(diver_pos):
		return chase_state
	else:
		return null

func force_update_rays() -> void:
	ray1.force_raycast_update()
	ray2.force_raycast_update()
	ray3.force_raycast_update()
