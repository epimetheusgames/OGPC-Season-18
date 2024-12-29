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
@onready var leg1: Bone2D = $"Skeleton/Torso/Thigh1/Calf1"
@onready var leg2: Bone2D = $"Skeleton/Torso/Thigh2/Calf2"

@onready var arm_target1: Node2D = $"ArmIkTarget1"
@onready var arm_target2: Node2D = $"ArmIkTarget2"

@onready var leg_target1: Node2D = $"LegIkTarget1"
@onready var leg_target2: Node2D = $"LegIkTarget2"

@onready var arrow: Node2D = $"Arrow"

var displayed_nametag: Label


# Leg oscillation (did i spell that right)
const DIST_FROM_BODY = -110
const MIN_LEG_DIST = -25
const MAX_LEG_DIST = 25

var leg_osc_counter1: float = 0
var leg_osc_counter2: float = 0
var osc_speed: float = 2.0

func _ready() -> void:
	var mod_stack: SkeletonModificationStack2D = $Skeleton.get_modification_stack()
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
	$Skeleton.set_modification_stack(mod_stack)
	
	displayed_nametag = $PlayerName.duplicate()
	$"../../../../../UI".add_child(displayed_nametag)
	
	if !diver.has_multiplayer_sync:
		return
	
	if diver.node_owner == 0 || diver.node_owner == Global.godot_steam_abstraction.steam_id:
		return
	
	if !Global.is_multiplayer || diver._is_node_owner():
		displayed_nametag.text = Steam.getFriendPersonaName(Global.godot_steam_abstraction.steam_id)
	else:
		displayed_nametag.text = Steam.getFriendPersonaName(int(diver.name))

func _process(delta: float) -> void:
	# Update label position.
	var offset_pos: Vector2 = head.global_position - get_viewport().get_camera_2d().get_screen_center_position()
	displayed_nametag.global_position = offset_pos - displayed_nametag.size / 2 + get_viewport_rect().size / 2 - Vector2(0, 40)
	
	# Update the arrow rotation
	arrow.global_rotation = diver.get_diver_movement().get_current_angle()
	
	osc_speed = diver.velocity.length() / 100
	
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

func get_hand1_position() -> Vector2:
	var pos: Vector2 = arm1.global_position
	var rot: float = arm1.get_bone_angle() + arm1.get_global_rotation()
	return pos + Util.angle_to_vector(rot, arm1.get_length())

func get_hand2_position() -> Vector2:
	var pos: Vector2 = arm2.global_position
	var rot: float = arm2.get_bone_angle() + arm2.get_global_rotation()
	return pos + Util.angle_to_vector(rot, arm2.get_length())
