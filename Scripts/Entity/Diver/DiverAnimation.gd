## Diver procedural animation system.
## It uses the built-in skeleton2d.
# Owned by: kaitaobenson

class_name DiverAnimation
extends Node2D

@onready var diver: Diver = get_parent()

@onready var skeleton: Skeleton2D = $"Skeleton"
@onready var head: Bone2D = $"Skeleton/Torso/Head"
@onready var arm1: Bone2D = $"Skeleton/Torso/UpperArm1/Forearm1"
@onready var arm2: Bone2D = $"Skeleton/Torso/UpperArm2/Forearm2"

@onready var arm_target1: Node2D = $"ArmIkTarget1"
@onready var arm_target2: Node2D = $"ArmIkTarget2"

@onready var leg_target1: Node2D = $"LegIkTarget1"
@onready var leg_target2: Node2D = $"LegIkTarget2"

@onready var move_arrow: Node2D = $"MoveArrow"
@onready var aim_arrow: Node2D = $"AimArrow"

# Leg oscillation
const DIST_FROM_BODY = -110
const MIN_LEG_DIST = -25
const MAX_LEG_DIST = 25

var leg_osc_counter1: float = 0
var leg_osc_counter2: float = 0
var osc_speed: float = 2.0

func _ready() -> void:
	var mod_stack: SkeletonModificationStack2D = skeleton.get_modification_stack()
	mod_stack = mod_stack.duplicate(true)
	var arm_mod1: SkeletonModification2DTwoBoneIK = mod_stack.get_modification(0)
	var arm_mod2: SkeletonModification2DTwoBoneIK = mod_stack.get_modification(1)
	var leg_mod1: SkeletonModification2DTwoBoneIK = mod_stack.get_modification(2)
	var leg_mod2: SkeletonModification2DTwoBoneIK = mod_stack.get_modification(3)
	arm_mod1.target_nodepath = arm_target1.get_path()
	arm_mod2.target_nodepath = arm_target2.get_path()
	leg_mod1.target_nodepath = leg_target1.get_path()
	leg_mod2.target_nodepath = leg_target2.get_path()
	mod_stack.set_modification(0, arm_mod1)
	mod_stack.set_modification(1, arm_mod2)
	mod_stack.set_modification(2, leg_mod1)
	mod_stack.set_modification(3, leg_mod2)
	
	skeleton.set_modification_stack(mod_stack)

func _process(delta: float) -> void:
	move_arrow.global_rotation = diver.get_diver_movement().get_current_angle()
	
	osc_speed = diver.velocity.length() / 100
	
	leg_osc_counter1 += delta * osc_speed
	leg_osc_counter2 += delta * osc_speed
	
	var t1: float = (cos(leg_osc_counter1) / 2.0) + 0.5
	var t2: float = (cos(leg_osc_counter2 + PI) / 2.0) + 0.5
	
	leg_target1.global_position = animate_leg_pos(t1)
	leg_target2.global_position = animate_leg_pos(t2)
	
	#aim_arrow.global_rotation = aim_arrow.global_position.angle_to_point(get_global_mouse_position())
	arm_target2.global_position = get_global_mouse_position()
	print(arm_target2.global_position)


func animate_leg_pos(t: float) -> Vector2:
	t = clamp(t, 0, 1)
	
	var leg_dist: float = lerp(MIN_LEG_DIST, MAX_LEG_DIST, t)
	
	var diver_pos = diver.global_position
	var diver_rot = diver.global_rotation
	
	var leg_offset = Util.angle_to_vector(diver_rot, leg_dist)
	var body_offset = Util.angle_to_vector(diver_rot - PI / 2, DIST_FROM_BODY)
	
	return diver_pos + leg_offset + body_offset


func get_head_position() -> Vector2:
	var pos: Vector2 = head.global_position
	var rot: float = head.get_bone_angle() + head.get_global_rotation()
	return pos + Util.angle_to_vector(rot, head.get_length())

# Hand pos setters / getters
func get_hand1_position() -> Vector2:
	var pos: Vector2 = arm1.global_position
	var rot: float = arm1.get_bone_angle() + arm1.get_global_rotation()
	return pos + Util.angle_to_vector(rot, arm1.get_length())

func set_hand1_position(pos: Vector2) -> void:
	arm_target1.global_position = pos

func get_hand2_position() -> Vector2:
	var pos: Vector2 = arm2.global_position
	var rot: float = arm2.get_bone_angle() + arm2.get_global_rotation()
	return pos + Util.angle_to_vector(rot, arm2.get_length())

func set_hand2_position(pos: Vector2) -> void:
	arm_target2.global_position = pos
