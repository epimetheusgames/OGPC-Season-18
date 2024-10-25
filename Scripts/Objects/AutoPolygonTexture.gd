@tool
class_name AutoPolygonTexture

extends Polygon2D

func _ready():
	if Engine.is_editor_hint():
		if !get_node_or_null("Collision"):
			var new_collision := StaticBody2D.new()
			new_collision.name = "Collision"
			add_child(new_collision, true)
		
		var new_collision_polygon := CollisionPolygon2D.new()
		new_collision_polygon.name = "Polygon"
		
		var new_occluder = LightOccluder2D.new()
		new_occluder.name = "LightOccluder"
		
		var new_occluder_polygon = OccluderPolygon2D.new()
		new_occluder.occluder = new_occluder_polygon
		
		add_child(new_occluder)
		add_child(new_collision, true)
		new_collision.add_child(new_collision_polygon, true)


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		var collision_object: CollisionObject2D = $"Collision"
		var collision_polygon: CollisionPolygon2D = $"Collision/Polygon"
		
		collision_polygon.polygon = self.polygon
		
		collision_polygon.position = Vector2.ZERO
		collision_object.position = Vector2.ZERO
		
		material.set_shader_parameter("points", polygon)
		material.set_shader_parameter("num_points", polygon.size())
		material.set_shader_parameter("global_position", global_position)
