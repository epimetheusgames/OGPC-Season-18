# Base class for all entities
class_name Entity
extends CharacterBody2D


@export var _has_physics := false
@export var uid := UID.new()
var save_resource := EntitySave.new()

func _process(delta: float) -> void:
	if _has_physics:
		move_and_slide()
		
	save_resource.position = position
	save_resource.velocity = velocity

func save_self() -> void:
	Global.save_load_framework._save_entity(Global.current_game_slot, uid, save_resource)
	
func load_self() -> void:
	save_resource = Global.save_load_framework._load_entity(Global.current_game_slot, uid)

# Setters and getters

## Set kinematic physics to true for the entity.
func enable_physics() -> void:
	_has_physics = true
	
## Disable kinematic physics for the entity.
func disable_physics() -> void:
	_has_physics = false
