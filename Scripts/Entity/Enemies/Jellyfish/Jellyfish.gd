class_name Jellyfish
extends Enemy

@onready var tentacles: JellyfishTentacles = $"Tentacles"

var boost_speed: float
var boost_duration: float
var boost_direction: Vector2

func _ready() -> void:
	state_machine.init(self)

func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)
	
	if boost_duration > 0:
		var target: Vector2 = global_position + boost_direction * 100
		velocity = drift_towards(target, boost_speed, 0.1)
		tentacles.tentacles_down(5)
		boost_duration -= delta
		
		if velocity.length() > 0.1:
			rotation = lerp_angle(rotation, velocity.angle() + PI/2, 0.05)
		
	else:
		tentacles.tentacles_up(3)
		velocity *= 0.99
	
	
	move_and_slide()


func boost(speed: float, duration: float, target_pos: Vector2):
	boost_speed = speed
	boost_duration = duration
	boost_direction = (target_pos - global_position).normalized()
