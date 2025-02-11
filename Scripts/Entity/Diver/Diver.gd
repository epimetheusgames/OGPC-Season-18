## The player of the game.
# Owned by: kaitaobenson

class_name Diver
extends Entity

var diver_state : Util.DiverState
 
@onready var diver_movement: DiverMovement = $"Movement"
@onready var diver_animation: DiverAnimation = $"Animation"
@onready var diver_combat: DiverCombat = $"Combat"
@onready var diver_flashlight: DiverFlashlight = $"Flashlight"
@onready var diver_inventory: DiverInventory = $"Inventory"
@onready var diver_stats: DiverStats = $"Stats"
@onready var water_polygon: Polygon2D = water_manager.get_children()[0] if water_manager else null

@export var water_manager: Node2D
@export var camera: Camera2D
@export var parallax: ParallaxBackground
@export var no_movement := false
@export var oxygen_loss := 0.01
@export var oxygen_boost_loss := 1

func _ready() -> void:
	if Global.godot_steam_abstraction && node_owner == 0 && !Global.godot_steam_abstraction.is_lobby_owner:
		node_owner = Global.godot_steam_abstraction.steam_id
	
	set_state(Util.DiverState.SWIMMING)
	
	if !Global.player || !is_instance_valid(Global.player):
		Global.player = self
	
	$BuoyancyComponent.waves = water_manager
	
	diver_movement.boosted.connect(_boost)

func _physics_process(_delta: float):
	diver_stats.oxygen_loss = oxygen_loss
	
	if camera && parallax:
		parallax.scroll_base_offset.y += 100
	
	if Global.is_multiplayer && has_multiplayer_sync && !_is_node_owner():
		move_and_slide()
		return
	
	if get_state() != Util.DiverState.DRIVING_SUBMARINE && get_state() != Util.DiverState.IN_MINISUB:
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

func _boost() -> void:
	diver_stats.oxygen_percentage -= oxygen_boost_loss

func get_diver_movement() -> DiverMovement:
	return diver_movement

func set_state(state : Util.DiverState):
	diver_state = state

func get_state() -> Util.DiverState:
	return diver_state

func get_diver_username() -> String:
	if !Global.godot_steam_abstraction:
		return "UNNAMED (RUN FULL GAME)"
	
	if _is_node_owner():
		return Steam.getFriendPersonaName(Global.godot_steam_abstraction.steam_id)
	else:
		return Steam.getFriendPersonaName(int(str(name)))

func get_diver_health() -> float:
	return diver_stats.get_health()

func get_diver_max_health() -> float:
	
	return 100
	#return diver_stats.get_max_health()

func get_oxygen() -> float:
	return diver_stats.oxygen_percentage
