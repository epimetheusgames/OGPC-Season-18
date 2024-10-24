extends Entity

const ACCELERATION: int = 300
const MAX_SPEED: int = 700

@onready var arrow = $"Arrow"

var current_angle: float = 0.0

func _ready() -> void:
	enable_physics()

func _physics_process(delta):
	movement(delta)

func movement(delta):
	if !Global.is_multiplayer || _is_node_owner():
		var input_vector = Vector2.ZERO
		
		# Input detection
		if Input.is_action_pressed("right"):
			input_vector += Vector2.RIGHT
		if Input.is_action_pressed("left"):
			input_vector += Vector2.LEFT
		if Input.is_action_pressed("up"):
			input_vector += Vector2.UP
		if Input.is_action_pressed("down"):
			input_vector += Vector2.DOWN
		
		input_vector = input_vector.normalized()

		# Smooth angle change
		if input_vector != Vector2.ZERO:
			var input_angle = input_vector.angle()
			current_angle = lerp_angle(current_angle, input_angle, 0.1)  # Smooth angle rotation

		arrow.rotation = current_angle
		
		if Input.is_action_just_pressed("move"):
			velocity += angle_to_speed(current_angle, ACCELERATION)
		
		#Global.godot_steam_abstraction.sync_var(arrow, "rotation")
	
	velocity *= 0.99
	
	# Clamp velocity
	if velocity.length() > MAX_SPEED:
		velocity = velocity.normalized() * MAX_SPEED
	
	move_and_slide()

func angle_to_speed(angle: float, speed: float) -> Vector2:
	return Vector2(speed * cos(angle), speed * sin(angle))
	
