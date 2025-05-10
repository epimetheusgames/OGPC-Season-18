## Diver procedural animation system.
## It uses the built-in skeleton2d.
## Owned by: kaitaobenson
class_name DiverAnimation
extends Node2D


@export var left_raycast: RayCast2D
@export var right_raycast: RayCast2D

## Diver root.
@onready var diver: Diver = get_parent()

## Diver IK skeleton root.
@onready var skeleton: Skeleton2D = $"Skeleton"

## Diver modification stack. What does this do?
@onready var mod_stack: SkeletonModificationStack2D = skeleton.get_modification_stack()
@onready var arm1: Bone2D = $"Skeleton/Torso/UpperArm1/Forearm1"
@onready var arm2: Bone2D = $"Skeleton/Torso/UpperArm2/Forearm2"
@onready var leg1: Bone2D = $"Skeleton/Torso/Thigh1/Calf1"
@onready var leg2: Bone2D = $"Skeleton/Torso/Thigh2/Calf2"
@onready var arm_target1: Node2D = $"ArmIkTarget1"
@onready var arm_target2: Node2D = $"ArmIkTarget2"
@onready var leg_target1: Node2D = $"LegIkTarget1"
@onready var leg_target2: Node2D = $"LegIkTarget2"

@onready var left_collision_point: Vector2 = left_raycast.get_collision_point()
@onready var right_collision_point: Vector2 = right_raycast.get_collision_point()

@export var default_sprite: Texture2D
@export var walking_sprite: Texture2D

var displayed_nametag: Label

## Leg oscillation
var leg_osc_counter1: float = 0
var leg_osc_counter2: float = 0

## Speed that the legs oscilate (units?)
var osc_speed: float = 2.0
var hand1_weapon_control: bool = false
var hand2_weapon_control: bool = false
var in_unlock_terminal_area := false
var unlock_terminal_in: UnlockTerminal

func _ready() -> void:
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
	
	displayed_nametag = $PlayerName.duplicate()
	
	# TODO: fix this
	var ui = $"../../../../../UI"
	if ui:
		ui.add_child(displayed_nametag)

func _process(delta: float) -> void:
	if Global.player.diver_movement.is_in_research_station:
		Global.brightness_modulate.color.v = 0.55
	else:
		Global.brightness_modulate.color.v = 0.1
	
	if Global.godot_steam_abstraction && Global.is_multiplayer:
		if diver._is_node_owner():
			displayed_nametag.text = Steam.getFriendPersonaName(Global.godot_steam_abstraction.steam_id)
		else:
			displayed_nametag.text = Steam.getFriendPersonaName(int(str(diver.name)))
	
	var head_pos: Vector2 = get_head_position()
	
	# Update label position.
	if get_viewport().get_camera_2d():
		var offset_pos: Vector2 = head_pos - get_viewport().get_camera_2d().get_screen_center_position()
		displayed_nametag.global_position = offset_pos - displayed_nametag.size / 2 + get_viewport_rect().size / 2 - Vector2(0, 40)
	
	if Global.godot_steam_abstraction && Global.is_multiplayer && !diver._is_node_owner():
		return
	
	_sync_multiplayer()
	
	# Legs
	if diver.get_state() != Diver.DiverState.IN_GRAVITY_AREA:
		$WalkingAnimation.stop()
		leg_target1.global_position = _animate_leg(1, delta)
		leg_target2.global_position = _animate_leg(2, delta)
		$Polygons/Calf1.texture = default_sprite
		$Polygons/Calf2.texture = default_sprite
	else:
		$WalkingAnimation.play("Walking", -1, 3 * diver.velocity.x / 392)
		$Polygons/Calf1.texture = walking_sprite
		$Polygons/Calf2.texture = walking_sprite
	
	# Arms
	if !hand1_weapon_control:
		arm_target1.position = _animate_arm(1, delta)
	else:
		hand1_weapon_control = false
	
	if !hand2_weapon_control:
		arm_target2.position = _animate_arm(2, delta)
	else:
		hand2_weapon_control = false

## Animates one of the legs (leg = 1 or leg = 2) with the delta time.
func _animate_leg(leg: int, delta: float) -> Vector2:
	const DIST_FROM_BODY = -110
	const MIN_LEG_DIST = -25
	const MAX_LEG_DIST = 25

	osc_speed = diver.velocity.length() / 100
	
	leg_osc_counter1 += delta * osc_speed
	leg_osc_counter2 += delta * osc_speed
	
	var t: float = 0.0
	if leg == 1:
		t = (cos(leg_osc_counter1) / 2.0) + 0.5
	elif leg == 2:
		t = (cos(leg_osc_counter2 + PI) / 2.0) + 0.5
	
	var leg_dist: float = lerp(MIN_LEG_DIST, MAX_LEG_DIST, t)
	
	var diver_pos = diver.global_position
	var diver_rot = diver.global_rotation
	
	var leg_offset = Util.angle_to_vector_radians(diver_rot, leg_dist)
	var body_offset = Util.angle_to_vector_radians(diver_rot - PI / 2, DIST_FROM_BODY)
	
	return diver_pos + leg_offset + body_offset

func _animate_arm(arm: int, _delta: float) -> Vector2:
	if arm == 1:
		return Vector2(38, 44)
	elif arm == 2:
		return Vector2(-38, 44)
	return Vector2.ZERO

## Syncs arm and leg IK targets in multiplayer.
func _sync_multiplayer() -> void:
	if Global.godot_steam_abstraction && Global.is_multiplayer:
		Global.godot_steam_abstraction.sync_var(arm_target1, "position")
		Global.godot_steam_abstraction.sync_var(arm_target2, "position")
		Global.godot_steam_abstraction.sync_var(leg_target1, "position")
		Global.godot_steam_abstraction.sync_var(leg_target2, "position")

# --- Body part setters / getters ---

func get_head_position() -> Vector2:
	var head: Bone2D = $"Skeleton/Torso/Head"
	
	var pos: Vector2 = head.global_position
	var rot: float = head.get_bone_angle() + head.get_global_rotation()
	return pos + Util.angle_to_vector_radians(rot, head.get_length())

## Get the END of the hand bone.
func get_hand1_position() -> Vector2:
	var arm1: Bone2D = $"Skeleton/Torso/UpperArm1/Forearm1"
	
	var pos: Vector2 = arm1.global_position
	var rot: float = arm1.get_bone_angle() + arm1.get_global_rotation()
	return pos + Util.angle_to_vector_radians(rot, arm1.get_length())

## Sets the target position for the hand.
func set_hand1_position(pos: Vector2) -> void:
	arm_target1.global_position = pos
	hand1_weapon_control = true

## Get the END of the hand bone.
func get_hand2_position() -> Vector2:
	var arm2: Bone2D = $"Skeleton/Torso/UpperArm2/Forearm2"
	
	var pos: Vector2 = arm2.global_position
	var rot: float = arm2.get_bone_angle() + arm2.get_global_rotation()
	return pos + Util.angle_to_vector_radians(rot, arm2.get_length())

## Sets the target position for the hand.
func set_hand2_position(pos: Vector2) -> void:
	arm_target2.global_position = pos
	hand2_weapon_control = true

func animate_collected_item(cost: int):
	$CollectItemAnimationText.text = "+" + str(cost)
	$CollectAnimation.play("Collect")

func _on_general_detection_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("unlock_terminal_area"):
		unlock_terminal_in = area.get_parent()
		in_unlock_terminal_area = true

func _on_general_detection_box_area_exited(area: Area2D) -> void:
	if area.is_in_group("unlock_terminal_area"):
		unlock_terminal_in = null
		in_unlock_terminal_area = false
