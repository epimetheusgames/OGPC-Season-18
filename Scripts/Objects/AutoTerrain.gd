# This script automatically fades between two repeating textures on the inside
# and edges of the polygon.
# Owned by: carsonetb

class_name AutoTerrain
extends Polygon2D

@export var smooth_mesh: bool = false
@export var shader: bool = true

var collision_body: StaticBody2D
var collision_polygon: CollisionPolygon2D

var occluder: LightOccluder2D

@onready var preloaded_texture: Texture2D = load("res://Assets/Art/Level/WallTexture.png")
@onready var preloaded_shader_material: Resource = preload("res://Scenes/Resource/Level/AutoPolygonTextureMaterial.tres")

func _ready() -> void:
	if !material: 
		material = preloaded_shader_material.duplicate(true)
	
	if shader:
		material.set_shader_parameter("points", polygon)
		material.set_shader_parameter("num_points", polygon.size())
		material.set_shader_parameter("global_position", global_position)
	
	if collision_body == null:
		collision_body = StaticBody2D.new()
		collision_body.add_to_group("environment_collision")
		add_child(collision_body)
	
	if collision_polygon == null:
		collision_polygon = CollisionPolygon2D.new()
		collision_body.add_child(collision_polygon)
		
		collision_polygon.polygon = self.polygon
		collision_polygon.position = offset
	
	if occluder == null:
		occluder = LightOccluder2D.new()
		add_child(occluder)
		occluder.occluder = OccluderPolygon2D.new()
		occluder.occluder.polygon = polygon
		occluder.position = offset
		occluder.occluder.cull_mode = OccluderPolygon2D.CULL_COUNTER_CLOCKWISE
		
	collision_body.collision_layer = 3
	
	print_tree_pretty()
