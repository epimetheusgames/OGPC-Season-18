# Coded by Xavier
class_name Submarine
extends Entity

@onready var submarine_movement = $"SubmarineMovement"
@onready var seat_pos = $"InteractionArea/SeatPos"

var navigation_obstacle : StaticBody2D

func _ready() -> void:
	if !Global.submarine:
		Global.submarine = self
	navigation_obstacle = StaticBody2D.new()
	navigation_obstacle.name = "NavigationObstacle"
	navigation_obstacle.collision_layer = 10000
	navigation_obstacle.collision_mask = 0
	navigation_obstacle.add_to_group("obstacles")
	add_child(navigation_obstacle, true)
	
	if get_node_or_null("Collision"):
		for child in get_node_or_null("Collision").get_children():
			var old_pos: Vector2 = child.global_position
			var old_rot: float = child.global_rotation
			$NavigationObstacle.add_child(child.duplicate())
			$"Collision".remove_child(child)
			add_child(child) 
			child.global_position = old_pos
			child.global_rotation = old_rot

func _physics_process(_delta: float) -> void:
	move_and_slide()
	velocity = submarine_movement.get_velocity()
	if Global.player.get_state() == Diver.DiverState.DRIVING_SUBMARINE:
		Global.player.global_transform = seat_pos.global_transform
