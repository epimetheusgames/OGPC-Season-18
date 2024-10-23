@tool
class_name AutoPolygonTexture
extends Polygon2D

func _ready():
	if !get_node_or_null("Collision"):
		var new_collision := StaticBody2D.new()
		new_collision.name = "Collision"
		
		var new_collision_polygon := CollisionPolygon2D.new()
		new_collision_polygon.name = "Polygon"
		
		add_child(new_collision, true)
		new_collision.add_child(new_collision_polygon, true)

func _process(delta: float) -> void:
	$Collision/Polygon.polygon = polygon
	$Collision/Polygon.position = Vector2.ZERO
	$Collision.position = Vector2.ZERO
	
	material.set_shader_parameter("points", polygon)
	material.set_shader_parameter("num_points", polygon.size())
	material.set_shader_parameter("global_position", global_position)
	
