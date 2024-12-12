## Jellyfish flap around in the water,
## and they also have cool tentacles that you can customize

# Owned by: kaitaobenson

class_name Jellyfish
extends Enemy

const BOOST_MULTIPLIER: float = 7
const ROTATION_SPEED: float = 2.0
const BOOST_DECAY_RATE: float = 0.9  # Controls how fast boost fades
const BOOST_DURATION: float = 0.2  # Boost lasts half a second

var time_since_boost: float = 0.0

var current_speed: float = 0
var boost_timer: float = 0.0

var target_velocity: Vector2
var target_rotation: float
var base_speed: float

@onready var nav_agent: NavigationAgent2D = $"NavigationAgent2D"
@onready var tentacles: JellyfishTentacles = $"Tentacles"

func _ready() -> void:
	_enemy_ready()
	base_speed = settings.base_speed

func _process(delta: float) -> void:
	_enemy_process(delta)
	nav_agent.target_position = target_position

	# Countdown boost timer (if needed for specific boost duration)
	if boost_timer > 0:
		boost_timer -= delta

	# Decay speed only if it's above BASE_SPEED
	if current_speed > base_speed:
		current_speed = lerp(current_speed, base_speed, BOOST_DECAY_RATE * delta)
	
	if position.distance_to(target_position) < 10:
		_target_reached()

func _physics_process(delta: float) -> void:
	time_since_boost += delta
	if time_since_boost > 3.0:
		time_since_boost = 0.0
		boost()
	
	if time_since_boost < 2.0 && time_since_boost > 1.0:
		update_targets()
	
	velocity = Util.better_vec2_lerp(velocity, target_velocity, 0.1, delta)
	global_rotation = lerp_angle(global_rotation, target_rotation, ROTATION_SPEED * delta)
	
	print(velocity)
	global_position += velocity * delta * 60

func boost():
	current_speed = base_speed * BOOST_MULTIPLIER
	boost_timer = BOOST_DURATION
	
	tentacles.boost(1.0)

func update_targets():
	var target_pos: Vector2 = nav_agent.get_next_path_position()
	
	target_velocity = (target_pos - global_position).normalized() * current_speed 
	target_rotation = velocity.angle() + PI / 2
