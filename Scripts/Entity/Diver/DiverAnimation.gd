## Diver procedural animation system.
class_name DiverAnimation
extends Node2D

@onready var diver: Diver = get_parent()

@onready var skeleton: Skeleton2D = $"Skeleton"
@onready var head: Bone2D = $"Skeleton/Torso/Head"

@onready var arm_target1: Node2D = $"ArmIkTarget1"
@onready var arm_target2: Node2D = $"ArmIkTarget2"

@onready var leg_target1: Node2D = $"LegIkTarget1"
@onready var leg_target2: Node2D = $"LegIkTarget2"

@onready var arrow: Node2D = $"Arrow"


# Leg oscillation (did i spell that right)
const DIST_FROM_BODY = -110
const MIN_LEG_DIST = -25
const MAX_LEG_DIST = 25

var leg_osc_counter1: float = 0
var leg_osc_counter2: float = 0
var osc_speed: float = 2.0

func _process(delta: float) -> void:
	# Update the arrow rotation
	arrow.global_rotation = diver.get_diver_movement().get_current_angle()
	
	var osc_speed: float =  diver.velocity.length() / 100
	
	leg_osc_counter1 += delta * osc_speed
	leg_osc_counter2 += delta * osc_speed
	
	var t1: float = (cos(leg_osc_counter1) / 2.0) + 0.5  # Cosine equation for leg 1
	var t2: float = (cos(leg_osc_counter2 + PI) / 2.0) + 0.5  # Cosine equation for leg 2 (phase-shifted by PI)
	
	# Set the leg positions based on the oscillation
	leg_target1.global_position = get_leg_pos(t1)
	leg_target2.global_position = get_leg_pos(t2)


func get_leg_pos(t: float) -> Vector2:
	# Ensure 't' is clamped between 0 and 1
	t = clamp(t, 0, 1)
	
	# Interpolate leg distance between min and max based on 't'
	var leg_dist: float = lerp(MIN_LEG_DIST, MAX_LEG_DIST, t)
	
	# Get diver's position and rotation
	var diver_pos = diver.global_position
	var diver_rot = diver.global_rotation
	
	# Calculate leg position
	var leg_offset = Util.angle_to_vector(diver_rot, leg_dist)
	var body_offset = Util.angle_to_vector(diver_rot - PI / 2, DIST_FROM_BODY)
	
	return diver_pos + leg_offset + body_offset

func get_head_position() -> Vector2:
	var pos: Vector2 = head.global_position
	var rot: float = head.get_bone_angle() + head.get_global_rotation()
	return pos + Util.angle_to_vector(rot, head.get_length())
