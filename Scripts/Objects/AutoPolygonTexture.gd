# This script automatically fades between two repeating textures on the inside
# and edges of the polygon.
@tool
class_name AutoPolygonTexture
extends Polygon2D

var collision_object: StaticBody2D
var collision_polygon: CollisionPolygon2D
var occluder: LightOccluder2D

@onready var preloaded_shader_material: Resource = preload("res://Scenes/Resource/Level/AutoPolygonTextureMaterial.tres")

func _process(delta: float) -> void:
	_make_sure_nodes_instantiated()
	
	# Update relevant polygons.
	collision_polygon.polygon = polygon
	occluder.occluder.polygon = polygon
	
	# Set all positions to zero which will cause them to be the same position
	# as the root Polygon2D (they are our children).
	collision_polygon.position = Vector2.ZERO
	collision_object.position = Vector2.ZERO
	occluder.position = Vector2.ZERO
	
	# Update shader parameters.
	material.set_shader_parameter("points", polygon)
	material.set_shader_parameter("num_points", polygon.size())
	material.set_shader_parameter("global_position", global_position)

# Check if neccesary children exist. If they don't, that means this node
# wasn't instantiated as a scene, this script was instantiated from the 
# add node dialog.
func _make_sure_nodes_instantiated() -> void:
	if Engine.is_editor_hint():
		# Check if Collision node exists, if not instantiate it.
		if !get_node_or_null("Collision"):
			var new_collision := StaticBody2D.new()
			new_collision.name = "Collision"
			new_collision.collision_mask = 129 # 10000001
			
			var new_collision_polygon := CollisionPolygon2D.new()
			new_collision_polygon.name = "Polygon"
			new_collision_polygon.visible = false
			
			add_child(new_collision, true)
			new_collision.add_child(new_collision_polygon, true)
			
			new_collision.owner = self
			new_collision_polygon.owner = new_collision
		
		# Check if LightOccluder node exists, if not instantiate it.
		if !get_node_or_null("LightOccluder"):
			var new_occluder = LightOccluder2D.new()
			new_occluder.name = "LightOccluder"
			new_occluder.visible = false
			
			var new_occluder_polygon = OccluderPolygon2D.new()
			new_occluder.occluder = new_occluder_polygon
		
			add_child(new_occluder)
			new_occluder.owner = self
		
		# Check if our shader material is setup. If not, instantiate a new one.
		if !material:
			material = preloaded_shader_material.duplicate(true)
			
	collision_object = $"Collision"
	collision_polygon = $"Collision/Polygon"
	occluder = $"LightOccluder"
