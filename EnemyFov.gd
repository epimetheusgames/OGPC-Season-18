## For checking whether an enemy can see the player
# Owned by: kaibenson

class_name EnemyFov
extends Node2D

@export var view_radius: float = 1000.0
@export var angle_of_view: float = 360.0

@export var see_through_walls: bool = false

func can_see_point(pos: Vector2) -> bool:
	# Check radius
	if global_position.distance_to(pos) > view_radius:
		return false
	
	# Check angle
	var angle_to_target: float = (pos - global_position).angle()
	var enemy_angle = global_rotation  
	var angle_diff = abs(angle_difference(angle_to_target, enemy_angle))
	
	if angle_diff > deg_to_rad(angle_of_view / 2.0):
		return false
	
	# Check walls
	if !see_through_walls:
		var query := PhysicsRayQueryParameters2D.create(global_position, pos)
		var result := get_world_2d().direct_space_state.intersect_ray(query)
		
		if result && result.collider is StaticBody2D:
			return false
	
	return true
