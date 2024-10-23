@tool
extends Node2D


func _process(delta: float) -> void:
	$Outline.points = $Body.polygon
	$Outline.position = $Body.position
	
	var shader_material: ShaderMaterial = $Body.material
	
	shader_material.set_shader_parameter("points", $Body.polygon)
	shader_material.set_shader_parameter("num_points", $Body.polygon.size())
	shader_material.set_shader_parameter("global_position", $Body.global_position)
	
