extends StaticBody2D

const GRAB_DIST: float = 650
const FOLLOW_DIST: float = 900

@onready var attack_collision: CollisionShape2D = $"ContinuousAttack/CollisionShape2D"
@onready var hurtbox: Hurtbox = $"Hurtbox"

@onready var ropes: Array[VerletRope] = [
	$"Rope1/VerletRope",
	$"Rope2/VerletRope",
	$"Rope3/VerletRope",
	$"Rope4/VerletRope",
]

var target_rope_position: Vector2
@onready var rope_position: Vector2 = global_position # Lerped value

func _ready() -> void:
	for rope in ropes:
		rope.end_pos_on = true
	
	hurtbox.died.connect(die)

func _process(delta: float) -> void:
	var diver_pos = Global.player.global_position
	
	var dist: float = global_position.distance_to(diver_pos)
	
	if dist < GRAB_DIST:
		target_rope_position = diver_pos
		
	elif dist < FOLLOW_DIST:
		target_rope_position = (diver_pos - global_position).normalized() * GRAB_DIST + global_position
		
	else:
		target_rope_position = Vector2(0, -500) + global_position
	
	rope_position = rope_position + (target_rope_position - rope_position) * 0.03
	
	for rope in ropes:
		rope.end_pos = rope_position
	
	attack_collision.global_position = rope_position

func die() -> void:
	queue_free()
