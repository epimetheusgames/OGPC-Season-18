## Base class for all enemies
# Owned by: kaibenson

class_name Enemy
extends CharacterBody2D

@export var hurtbox: Hurtbox
@export var animations: AnimatedSprite2D
@export var nav_agent: NavigationAgent2D
@export var enemy_fov: EnemyFov

@export var drop_item: BaseItem



# Some standard movement options to use
func spring_towards(pos: Vector2, spring_strength: float, spring_damping: float, delta: float) -> void:
	var force: Vector2 = ((pos - global_position) * spring_strength) - (velocity * spring_damping)
	velocity += force * delta
	
	if velocity.length() > 0.1:
		rotation = velocity.angle()

func accelerate_towards(pos: Vector2, accel: float, delta: float) -> void:
	velocity += (pos - global_position).normalized() * accel
	
	if velocity.length() > 0.1:
		rotation = velocity.angle()

func move_towards(pos: Vector2, speed: float, delta: float) -> void:
	velocity = (pos - global_position).normalized() * speed
	print(velocity)
	if velocity.length() > 0.1:
		rotation = velocity.angle()

# Other util
func get_diver_pos() -> Vector2:
	if Global.player:
		return Global.player.global_position
	
	return Vector2.ZERO
