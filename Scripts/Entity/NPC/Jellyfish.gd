## Jellyfish flap around in the water,
## and they also have cool tentacles that you can customize
# Owned by: kaitaobenson
class_name Jellyfish
extends Enemy

#TODO: FIX THIS KAI
"""
const BOOST_MULTIPLIER: float = 7
const ROTATION_SPEED: float = 0.3
const BOOST_DECAY_RATE: float = 0.9  # Controls how fast boost fades
const BOOST_DURATION: float = 0.2  # Boost lasts half a second

var time_since_boost: float = 0.0

var current_speed: float = 0
var boost_timer: float = 0.0

var target_velocity: Vector2
var target_rotation: float
var base_speed: float

@export var friendly: bool

@onready var nav_agent: NavigationAgent2D = $"NavigationAgent2D"
@onready var tentacles: JellyfishTentacles = $"Tentacles"

var nav_target: Vector2

func _ready() -> void:
	super()
	base_speed = settings.base_speed
	
	while true:
		await get_tree().create_timer(0.1).timeout
		nav_agent.target_position = target_position
		nav_target = nav_agent.get_next_path_position()
		if !nav_agent.is_target_reachable():
			_target_reached()

func _process(delta: float) -> void:
	super(delta)

	# Countdown boost timer (if needed for specific boost duration)
	if boost_timer > 0:
		boost_timer -= delta

	# Decay speed only if it's above BASE_SPEED
	if current_speed > base_speed:
		current_speed = lerp(current_speed, base_speed, BOOST_DECAY_RATE * delta)
	
	if position.distance_to(target_position) < 50 && !friendly:
		_target_reached()
	
	for rope in tentacles.ropes:
		rope.is_on_screen = $VisibleOnScreenNotifier2D.is_on_screen()

func _physics_process(delta: float) -> void:
	time_since_boost += delta
	if time_since_boost > 3.0:
		time_since_boost = 0.0
		boost()
	
	update_targets()
	
	velocity = Util.better_vec2_lerp(velocity, target_velocity, 0.1, delta)
	global_rotation = Util.better_angle_lerp(global_rotation, target_rotation, ROTATION_SPEED, delta)
	
	global_position += velocity * delta * 60

	move_and_slide()

func boost():
	current_speed = target_speed * BOOST_MULTIPLIER
	boost_timer = BOOST_DURATION
	
	tentacles.boost(1.0)

func update_targets():
	var target_pos: Vector2 = nav_agent.get_next_path_position()
	
	target_velocity = (target_pos - global_position).normalized() * current_speed 
	target_rotation = velocity.angle() + PI / 2
	if global_position.distance_squared_to(target_pos) > 200 ** 2:
		for i in range(tentacles.ropes.size()):
			tentacles.ropes[i].gravity = -target_velocity.normalized() * 10
	else:
		for i in range(tentacles.ropes.size()):
			tentacles.ropes[i].gravity = target_velocity.normalized() * 10
"""
