# Coded by Xavier
class_name Submarine
extends Entity

@onready var submarine_movement = $"SubmarineMovement"
@onready var seat_pos = $"InteractionArea/SeatPos"
@onready var aura = $"SubmarineAura"

var navigation_obstacle : StaticBody2D
var collision_shapes : Array[CollisionPolygon2D]

func _ready() -> void:
	$"Hurtboxes/CageHurtbox".died.connect(cage_broken)
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
			collision_shapes.append(child)
			child.global_position = old_pos
			child.global_rotation = old_rot

func _process(delta: float) -> void:
	aura.global_rotation = 0.0
	if Global.player.get_state() == Diver.DiverState.DRIVING_SUBMARINE:
		Global.player.global_transform = seat_pos.global_transform

func _physics_process(_delta: float) -> void:
	velocity = submarine_movement.get_velocity()
	move_and_slide()

## Called when cage breaks
func cage_broken():
	collision_shapes.erase($"Cage")
	$"Cage".queue_free()
	$"NavigationObstacle/Cage".queue_free()
	$"Hurtboxes/CageHurtbox".queue_free()
	$"Hurtboxes/BubbleHurtbox".hurt_by_enemy = true
