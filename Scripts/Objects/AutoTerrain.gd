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
	texture = preloaded_texture
	texture_repeat = TEXTURE_REPEAT_ENABLED
	material = preloaded_shader_material
	
	if shader:
		material.set_shader_parameter("points", polygon)
		material.set_shader_parameter("num_points", polygon.size())
		material.set_shader_parameter("global_position", global_position)
	
	if collision_body == null:
		collision_body = StaticBody2D.new()
		add_child(collision_body)
	
	if collision_polygon == null:
		collision_polygon = CollisionPolygon2D.new()
		collision_body.add_child(collision_polygon)
		
		collision_polygon.polygon = self.polygon
	
	if occluder == null:
		occluder = LightOccluder2D.new()
		add_child(occluder)
		occluder.occluder = OccluderPolygon2D.new()
		occluder.occluder.polygon = get_smaller_polygon(polygon, 0)

func get_smaller_polygon(points: PackedVector2Array, shrink_distance: float) -> PackedVector2Array:
	if points.size() == 0:
		return points
	
	var center: Vector2 = Vector2.ZERO
	for vertex in polygon:
		center += vertex
	center /= points.size()
	
	var smaller_polygon = PackedVector2Array()
	for vertex in points:
		var direction: Vector2 = (vertex - center).normalized()
		smaller_polygon.append(vertex - direction * shrink_distance)
	
	return smaller_polygon
