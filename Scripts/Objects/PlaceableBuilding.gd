class_name PlaceableBuilding
extends Node2D


const transparency_when_not_placed := 0.5
const raycast_length_mul = 0.5

@export var scene: FilePathResource
@export var building_sprite: Sprite2D
@export var building_collision: StaticBody2D
@export var base_position: Node2D
@export var detection_area: Area2D
@export var max_occupants: int
@export var current_occupants: int

@onready var raycasts: Node2D = $Raycasts

var placed := false
var offset: Vector2
var size: Vector2
var placed_by: Diver

func _ready() -> void:
	if !building_sprite:
		Global.print_error("Placeable building has no sprite. Path: " + str(get_path()))
		
		for child in get_children():
			if child is Sprite2D:
				Global.print_debug("DEBUG: Found sprite as child, using.")
				building_sprite = child
	
	if !building_collision:
		Global.print_error("Placeable building has no collision. Path: " + str(get_path()))
		
		for child in get_children():
			if child is StaticBody2D:
				Global.print_debug("DEBUG: Found static body as child, using.")
				building_collision = child
		
		# This is likely to happen.
		for child in building_sprite.get_children():
			if child is StaticBody2D:
				Global.print_debug("DEBUG: Found static body as child of sprite, using.")
				building_collision = child
	
	if !base_position:
		Global.print_error("Placeable building has no base position. Path: " + str(get_path()))
		
		for child in get_children():
			if child is Node2D && child.name != "Raycasts":
				Global.print_debug("DEBUG: Found position (not raycasts) as child, using.")
				base_position = child
	
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
	
	Global.save_load_framework.save_nodes.connect(_save_self)

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
			building_sprite.position = Util.better_vec2_lerp(building_sprite.position, to_local(placement_info[0]) - offset.rotated(placement_info[1].angle() - PI / 2.0), 0.9, delta)
			building_sprite.rotation = Util.better_angle_lerp(building_sprite.rotation, placement_info[1].angle() + deg_to_rad(90), 0.2, delta)
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
		var point_intersecting := Util.do_pointcast(get_world_2d(), raycast.global_position)
		if point_intersecting && !point_intersecting[0]["collider"] is Entity:
			continue
		
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
		Global.godot_steam_abstraction.sync_var(self, "max_occupants")
		Global.godot_steam_abstraction.sync_var(self, "current_occupants")

func _save_self() -> void:
	Global.current_game_save.node_saves.append(
		NodeSaver.create(
			Global.current_mission_node, 
			self, 
			[
				"position", 
				"rotation", 
				"placed",
				"max_occupants",
				"current_occupants"
			],
		)
	)
