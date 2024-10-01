# Base class for all entities
class_name Entity
extends CharacterBody2D


var entity_type = "Entity"

@export var _has_physics := false
@export var uid := UID.new()

# Defaults to the server unless set by another node.
# WARNING: Most entities besides players should be operated by the server,
# because we can only be sure that the server is connected.
@export var multiplayer_authority = 1

var save_resource := EntitySave.new()

func _ready() -> void:
	set_multiplayer_authority(multiplayer_authority, true)

func _process(delta: float) -> void:
	if _has_physics:
		move_and_slide()
	
	if Global.is_multiplayer && !_is_node_owned_by_current_instance():
		return
	
	save_resource.position = position
	save_resource.velocity = velocity
	
	# Sync variables so that everything's the same.
	if Global.is_multiplayer:
		var multiplayer_type := Global.get_multiplayer_type()
		if multiplayer_type == Global.MULTIPLAYER_MODE.LOCAL_NETWORK:
			_local_sync_variables_multiplayer.rpc(position, velocity, rotation)
		if multiplayer_type == Global.MULTIPLAYER_MODE.GD_SYNC:
			_gd_sync_variables_multiplayer()

## Check if the entity has a component of a specific class
func has_component(component_type: String) -> bool:
	if get_component(component_type):
		return true
	
	return false

## Get the component with the specific component class
func get_component(component_type: String) -> Node:
	for child in get_children():
		if "component_name" in child && child.component_name == component_type:
			return child
	
	return null

# -- Save Load --

func save_self() -> void:
	Global.save_load_framework._save_entity(Global.current_game_slot, uid, save_resource)
	
func load_self() -> void:
	save_resource = Global.save_load_framework._load_entity(Global.current_game_slot, uid)

# -- Networking --

@rpc("call_local", "unreliable")
func _local_sync_variables_multiplayer(pos: Vector2, motion: Vector2, rot: float) -> void:
	position = pos
	velocity = motion
	rotation = rot

func _gd_sync_variables_multiplayer() -> void:
	GDSync.sync_var(self, "position")
	GDSync.sync_var(self, "velocity")
	GDSync.sync_var(self, "rotation")

func _is_node_owned_by_current_instance() -> bool:
	var multiplayer_type: Global.MULTIPLAYER_MODE = Global.get_multiplayer_type()
	
	if multiplayer_type == Global.MULTIPLAYER_MODE.GD_SYNC:
		if GDSync.is_gdsync_owner(self):
			return true
	elif multiplayer_type == Global.MULTIPLAYER_MODE.LOCAL_NETWORK:
		if is_multiplayer_authority():
			return true
	
	return false

# -- Setters and getters --

## Set kinematic physics to true for the entity.
func enable_physics() -> void:
	_has_physics = true
	
## Disable kinematic physics for the entity.
func disable_physics() -> void:
	_has_physics = false

## Get the class of the Entity.
func get_entity_type() -> String:
	return entity_type
