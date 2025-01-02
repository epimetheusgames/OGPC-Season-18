## The player of the game.
# Owned by: kaitaobenson

class_name Diver
extends Entity

var diver_state : Util.DiverState
 
@onready var diver_movement: DiverMovement = $"Movement"
@onready var diver_animation: DiverAnimation = $"Animation"
@onready var diver_combat: DiverCombat = $"Combat"
@onready var diver_flashlight: DiverFlashlight = $"Flashlight"
@onready var water_polygon: Polygon2D = water_manager.get_children()[0] if water_manager else null

@export var water_manager: Node2D
@export var no_movement := false
@export var camera: Camera2D
@export var parallax: ParallaxBackground

func _ready() -> void:
	if node_owner == 0 && !Global.godot_steam_abstraction.is_lobby_owner:
		node_owner = Global.godot_steam_abstraction.steam_id
	
	set_state(Util.DiverState.SWIMMING)
	if !Global.player || !is_instance_valid(Global.player):
		Global.player = self
	$BuoyancyComponent.waves = water_manager

func _physics_process(_delta: float):
	if camera && parallax:
		parallax.scroll_base_offset.y += 100
	
	if Global.is_multiplayer && has_multiplayer_sync && !_is_node_owner():
		move_and_slide()
		return
	
	if get_state() != Util.DiverState.DRIVING_SUBMARINE:
		velocity = diver_movement.get_velocity()
		
		var target_angle: float = velocity.angle() + PI/2
		
		var angle_diff: float = angle_difference(rotation, target_angle)
		rotation += clamp(angle_diff * 0.1, -0.1, 0.1)
	
	move_and_slide()
	
	if Global.is_multiplayer && has_multiplayer_sync && _is_node_owner():
		Global.godot_steam_abstraction.sync_var($Animation/ArmIkTarget1, "global_position")
		Global.godot_steam_abstraction.sync_var($Animation/ArmIkTarget2, "global_position")
		Global.godot_steam_abstraction.sync_var($Animation/LegIkTarget1, "global_position")
		Global.godot_steam_abstraction.sync_var($Animation/LegIkTarget2, "global_position")

func get_diver_movement() -> DiverMovement:
	return diver_movement

func set_state(state : Util.DiverState):
	diver_state = state

func get_state() -> Util.DiverState:
	return diver_state
