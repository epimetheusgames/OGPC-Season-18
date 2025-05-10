extends Node2D



func _on_area_2d_area_entered(area: Area2D) -> void:
	add_to_group("civillian_spawn_points")
