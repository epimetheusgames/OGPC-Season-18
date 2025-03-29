## The player of the game.
# Owned by: kaitaobenson

class_name Diver
extends Entity

## General state of the diver. In the future substates should be implemented.
var diver_state: Util.DiverState
 
## Node that handles movement.
@onready var diver_movement: DiverMovement = $"Movement"

## Node that handles skeletal animations.
@onready var diver_animation: DiverAnimation = $"Animation"

## Node that handles combat and combat animations.
@onready var diver_combat: DiverCombat = $"Combat"

## Handles the flashlight, shouldn't be a node probably.
@onready var diver_flashlight: DiverFlashlight = $"Light"

## Handles diver's inventory "backend".
@onready var diver_inventory: DiverInventory = $"Inventory"

## Handles health, oxygen, etc.
@onready var diver_stats: DiverStats = $"Stats"

## The polygon attached to the waves (the probably don't exist because Kai is mean)
@onready var water_polygon: Polygon2D = water_manager.get_children()[0] if water_manager else null
@onready var saveable_timer := get_tree().create_timer(0.5)

## FilePath of the diver.
@export var diver_scene: FilePathResource

## Waves root.
@export var water_manager: Node2D

## The camera.
@export var camera: Camera2D

## Bubbles paralax.
@export var parallax: ParallaxBackground

## Turns on and off diver movement. I'm not sure if this is really used.
@export var no_movement := false

## The amount of oxygen percentage lost every frame.
@export var oxygen_loss := 0.01

## The amount of oxygen percentage lost when the player boosts.
@export var oxygen_boost_loss := 1

## Player follower
@export var follower: CivillianFollower

# --- OVERRIDES ---

func _ready() -> void:
	if Global.godot_steam_abstraction && node_owner == 0 && !Global.godot_steam_abstraction.is_lobby_owner:
		node_owner = Global.godot_steam_abstraction.steam_id
	
	set_state(Util.DiverState.SWIMMING)
	
	# When instantiated this is probably going to be the default player.
	if !Global.is_multiplayer || _is_node_owner():
		Global.player = self
	
	$BuoyancyComponent.waves = water_manager
	
	diver_movement.boosted.connect(_boost)
	
	if Global.save_load_framework:
		Global.save_load_framework.save_nodes.connect(_save)
	
	if !(Global.is_multiplayer && Global.godot_steam_abstraction && !_is_node_owner()):
		camera.enabled = true
	else:
		camera.enabled = false

func _physics_process(_delta: float):
	diver_stats.oxygen_loss = oxygen_loss
	
	if get_state() == Util.DiverState.IN_GRAVITY_AREA:
		$Body.disabled = true
		$LargeBody.disabled = false
	else:
		$Body.disabled = false
		$LargeBody.disabled = true
	
	if get_state() == Util.DiverState.IN_SUBMARINE || get_state() == Util.DiverState.DRIVING_SUBMARINE:
		z_index = 21
	else:
		z_index = 20
	
	if camera && parallax:
		parallax.scroll_base_offset.y += 100
	
	if Global.is_multiplayer && has_multiplayer_sync && !_is_node_owner():
		move_and_slide()
		return
	
	_update_vel_rot()
	move_and_slide()
	
	_sync_multiplayer()

# --- HELPERS ---

# Syncs limb IK targets in multiplayer.
func _sync_multiplayer() -> void:
	if Global.is_multiplayer && has_multiplayer_sync && _is_node_owner():
		Global.godot_steam_abstraction.sync_var($Animation/ArmIkTarget1, "global_position")
		Global.godot_steam_abstraction.sync_var($Animation/ArmIkTarget2, "global_position")
		Global.godot_steam_abstraction.sync_var($Animation/LegIkTarget1, "global_position")
		Global.godot_steam_abstraction.sync_var($Animation/LegIkTarget2, "global_position")

# Saves the player, should be attached to a signal.
func _save() -> void:
	Global.current_game_save.node_saves.append(
		NodeSaver.create(
			Global.current_mission_node, 
			self, 
			[
				"position",
				"rotation",
				"velocity",
				"diver_state",
			],
			{
				get_path_to(diver_movement): [
					"velocity",
					"current_angle",
					"is_in_gravity_area",
				],
				get_path_to(diver_stats): [
					"health",
					"oxygen_percentage",
				],
				get_path_to(diver_combat): [
					"selected_weapon",
				],
			},
			diver_scene,
		)
	)

# Update player velocity and rotation.
func _update_vel_rot() -> void:
	if get_state() == Util.DiverState.DRIVING_SUBMARINE:
		return
		
	velocity = diver_movement.get_velocity()
	
	if get_state() == Util.DiverState.IN_GRAVITY_AREA:
		return
	
	var target_angle: float = velocity.angle() + PI/2
	
	var angle_diff: float = angle_difference(rotation, target_angle)
	rotation += clamp(angle_diff * 0.1, -0.1, 0.1)

# Updates oxygen, should be attached to a signal.
func _boost() -> void:
	diver_stats.oxygen_percentage -= oxygen_boost_loss

# --- SETTERS AND GETTERS --- 

# Gets general diver state.
func get_state() -> Util.DiverState:
	return diver_state

# Sets general diver state.
func set_state(state : Util.DiverState):
	diver_state = state

# Gets the diver username if the game is in multiplayer mode.
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
	return diver_stats.get_max_health()

func get_oxygen() -> float:
	return diver_stats.oxygen_percentage
