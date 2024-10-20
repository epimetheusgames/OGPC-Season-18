# Base class for all entities
class_name Entity

extends CharacterBody2D


var entity_type = "Entity"

@export var _has_physics := false
@export var uid := UID.new()

# Defaults to the server unless set by another node.
# WARNING: Most entities besides players should be operated by the server,
# because we can only be sure that the server is connected.
@export var has_multiplayer_sync: bool = true
@export var sync_by_increment: bool = false
@export var sync_increment: float = 0

var node_owner = 0
var save_resource := EntitySave.new()
var components_dictionary = {}

func _process(delta: float) -> void:
	_entity_process(delta)

func _entity_process(delta: float) -> void:
	if _has_physics:
		move_and_slide()
	
	save_resource.position = position
	save_resource.velocity = velocity
	
	# Sync variables so that everything's the same.
	if Global.is_multiplayer && has_multiplayer_sync && _is_node_owner():
		Global.godot_steam_abstraction.sync_var(self, "position")
		Global.godot_steam_abstraction.sync_var(self, "velocity")
		Global.godot_steam_abstraction.sync_var(self, "rotation")

## Check if the entity has a component of a specific class
func has_component(component_type: String) -> bool:
	if get_component(component_type):
		return true
	
	return false

## Get the component with the specific component class
func get_component(component_type: String) -> Node:
	if component_type in components_dictionary:
		return components_dictionary[component_type]
	
	return null

func add_component(component_type: String, component: BaseComponent) -> void:
	components_dictionary[component_type] = component

# -- Multiplayer --

func _is_node_owner() -> bool:
	if node_owner == 0:
		return Global.godot_steam_abstraction.is_lobby_owner
	else:
		return Global.godot_steam_abstraction.steam_id == node_owner

# -- Save Load --

func save_self() -> void:
	Global.save_load_framework._save_entity(Global.current_game_slot, uid, save_resource)
	
func load_self() -> void:
	save_resource = Global.save_load_framework._load_entity(Global.current_game_slot, uid)

# -- Setters and getters --

## Can be overriden by children to have a custom set velocity function.
func set_new_velocity(new_velocity: Vector2) -> void:
	velocity = new_velocity

## Set kinematic physics to true for the entity.
func enable_physics() -> void:
	_has_physics = true
	
## Disable kinematic physics for the entity.
func disable_physics() -> void:
	_has_physics = false

## Get the class of the Entity.
func get_entity_type() -> String:
	return entity_type
