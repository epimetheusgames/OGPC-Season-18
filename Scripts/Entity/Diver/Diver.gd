## The player of the game.
# Owned by: kaitaobenson

class_name Diver
extends Entity

enum DiverState {
	SWIMMING,
	IN_SUBMARINE,
	DRIVING_SUBMARINE,
	OPERATING_MODULE,
	IN_GRAVITY_AREA,
}

var diver_state: DiverState
 
@onready var diver_movement: DiverMovement = $"Movement"
@onready var diver_animation: DiverAnimation = $"Animation"
@onready var diver_combat: DiverCombat = $"Combat"
@onready var diver_flashlight: DiverFlashlight = $"Light"  # Shouldn't be a node probably.
@onready var diver_inventory: DiverInventory = $"Inventory"  # Handles diver's inventory "backend".
@onready var diver_stats: DiverStats = $"Stats"  # Handles health, oxygen, etc.

@export var camera: DiverCamera

@export var diver_scene: FilePathResource  # FilePath of the diver ??


## Player follower
@export var follower: CivillianFollower

# --- OVERRIDES ---

func _ready() -> void:
	super()
	
	if Global.godot_steam_abstraction && node_owner == 0 && !Global.godot_steam_abstraction.is_lobby_owner:
		node_owner = Global.godot_steam_abstraction.steam_id
	
	set_state(DiverState.SWIMMING)
	
	# When instantiated this is probably going to be the default player.
	if !Global.is_multiplayer || _is_node_owner():
		Global.player = self
	
	Global.player_array.append(self)
	
	if Global.save_load_framework:
		Global.save_load_framework.save_nodes.connect(_save)
	
	diver_stats.hurtbox.damaged.connect(_damaged)

func _damaged(damage_amount: float, by: Attackbox) -> void:
	modulate.g = 0.0
	modulate.b = 0.0
	await get_tree().create_timer(0.6).timeout
	modulate.g = 1.0
	modulate.b = 1.0
	

func _process(delta: float) -> void:
	super(delta)
	
	if !Global.is_multiplayer || _is_node_owner():
		Global.player = self

func _physics_process(_delta: float):
	
	if get_state() == DiverState.IN_GRAVITY_AREA:
		$Body.disabled = true
		$LargeBody.disabled = false
	elif get_state() == DiverState.DRIVING_SUBMARINE:
		$Body.disabled = true
		$LargeBody.disabled = true
	else:
		$Body.disabled = false
		$LargeBody.disabled = true
	
	if get_state() == DiverState.IN_SUBMARINE || get_state() == DiverState.DRIVING_SUBMARINE:
		z_index = 21
	else:
		z_index = 100
	
	# Camera
	if !(Global.is_multiplayer && Global.godot_steam_abstraction && 	_is_node_owner()):
		camera.enabled = true
	else:
		camera.enabled = false
	
	if diver_animation.in_unlock_terminal_area:
		camera.zoom = Util.better_vec2_lerp(camera.zoom, Vector2(3, 3), 0.2, _delta)
		camera.global_position = Util.better_vec2_lerp(camera.global_position, Global.research_station.unlock_terminal.global_position, 0.1, _delta)
		Global.current_mission_node.get_node("UILayer").visible = false
	else:
		camera.zoom = Util.better_vec2_lerp(camera.zoom, Vector2.ONE, 0.2, _delta)
		camera.position = Util.better_vec2_lerp(camera.position, Vector2.ZERO, 0.1, _delta)
		Global.current_mission_node.get_node("UILayer").visible = true
	
	#if camera && parallax:
	#	parallax.scroll_base_offset.y += 100
	
	if Global.is_multiplayer && has_multiplayer_sync && !_is_node_owner():
		move_and_slide()
		return
	
	move_and_slide()
	
	_sync_multiplayer()

func _exit_tree() -> void:
	Global.player_array.pop_at(Global.player_array.find(self))

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
					"current_money",
				],
				get_path_to(diver_combat): [
					"selected_weapon",
					"unlocked_weapons",
				],
				get_path_to(diver_inventory): [
					"collected_item_paths",
				]
			},
			false,
			diver_scene,
		)
	)


# --- SETTERS AND GETTERS --- 

# Gets general diver state.
func get_state() -> DiverState:
	return diver_state

# Sets general diver state.
func set_state(state : DiverState) -> void:
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
	return diver_stats.oxygen
