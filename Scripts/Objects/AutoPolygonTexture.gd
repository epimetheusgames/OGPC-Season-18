@tool
class_name AutoPolygonTexture
extends Polygon2D

func _ready():
	if Engine.is_editor_hint():
		var new_collision := StaticBody2D.new()
		new_collision.name = "Collision"
		new_collision.collision_mask = 129
		
		var new_collision_polygon := CollisionPolygon2D.new()
		new_collision_polygon.name = "Polygon"
		
		var new_occluder = LightOccluder2D.new()
		new_occluder.name = "LightOccluder"
		
		var new_occluder_polygon = OccluderPolygon2D.new()
		new_occluder.occluder = new_occluder_polygon
		
		add_child(new_collision, true)
		new_collision.add_child(new_collision_polygon, true)
		add_child(new_occluder)

func _process(delta: float) -> void:
	var collision_object: CollisionObject2D = $"Collision"
	var collision_polygon: CollisionPolygon2D = $"Collision/Polygon"
	var occluder = $"LightOccluder"
	
	collision_polygon.polygon = polygon
	occluder.occluder.polygon = polygon
	
	collision_polygon.position = Vector2.ZERO
	collision_object.position = Vector2.ZERO
	occluder.position = Vector2.ZERO
	
	material.set_shader_parameter("points", polygon)
	material.set_shader_parameter("num_points", polygon.size())
	material.set_shader_parameter("global_position", global_position)
