class_name PlaceableBuilding
extends Node2D


const transparency_when_not_placed := 0.5
const raycast_length_mul = 0.5

@export var building_sprite: Sprite2D
@export var building_collision: StaticBody2D
@export var base_position: Node2D

@onready var raycasts: Node2D = $Raycasts

var placed := false
var offset: Vector2
var size: Vector2
var placed_by: Diver

func _ready() -> void:
	if !building_sprite:
		print("ERROR: Placeable building has no sprite. Path: " + str(get_path()))
		return
	
	if !building_collision:
		print("ERROR: Placeable building has no collision. Path: " + str(get_path()))
		return
	
	if !base_position:
		print("ERROR: Placeable building has no base position. Path: " + str(get_path()))
	
	# Make sure sprites and collisions are a child of this.
	if !building_sprite.find_parent(name):
		building_sprite.reparent(self)
	building_collision.reparent(building_sprite)
	if !base_position.find_parent(name):
		base_position.reparent(self)
		
	size = building_sprite.texture.get_size() * building_sprite.scale
	offset = building_sprite.position - base_position.position
	
	for child: RayCast2D in raycasts.get_children():
		child.target_position = child.target_position.normalized() * size.length() * raycast_length_mul

func _process(delta: float) -> void:
	if Global.godot_steam_abstraction && Global.is_multiplayer && !placed_by._is_node_owner():
		return
	
	if !placed:
		for child in building_collision.get_children():
			child.disabled = true
		
		global_position = get_global_mouse_position()
		building_sprite.modulate.a = transparency_when_not_placed
		
		var placement_info := _check_raycasts()
		if placement_info:
			building_sprite.position = to_local(placement_info[0]) - placement_info[1] * offset
			building_sprite.rotation = placement_info[1].angle() + deg_to_rad(90)
			if Input.is_action_just_pressed("mouse_left_click"):
				placed = true
				_sync_multiplayer()
		else:
			building_sprite.position = Vector2.ZERO
			building_sprite.rotation = 0
	else:
		for child in building_collision.get_children():
			child.disabled = false
			
		building_collision.collision_layer = 1
		building_sprite.modulate.a = 1

# Returns an array of two vectors, the position and normal. 
# Or null.
func _check_raycasts() -> Array[Vector2]:
	var closest_info: Array[Vector2] = []
	for raycast: RayCast2D in raycasts.get_children():
		var collider := raycast.get_collider()
		if (!raycast.is_colliding() || \
				(closest_info && closest_info[0].distance_squared_to(raycast.global_position) < \
								 raycast.get_collision_point().distance_squared_to(raycast.global_position)) || \
				collider is Entity
		):
			continue
		closest_info = [raycast.get_collision_point(), raycast.get_collision_normal()]
	return closest_info

func _sync_multiplayer() -> void:
	if Global.godot_steam_abstraction && Global.is_multiplayer && placed_by._is_node_owner():
		Global.godot_steam_abstraction.sync_var(building_sprite, "position")
		Global.godot_steam_abstraction.sync_var(building_sprite, "rotation")
		Global.godot_steam_abstraction.sync_var(building_sprite, "modulate")
		Global.godot_steam_abstraction.sync_var(building_collision, "collision_layer")
		Global.godot_steam_abstraction.sync_var(self, "placed")
