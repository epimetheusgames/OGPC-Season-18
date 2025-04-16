## Base class for all enemies
# Owned by: kaibenson

class_name Enemy
extends Entity

@export var hurtbox: Hurtbox
@export var animations: AnimatedSprite2D
@export var nav_agent: NavigationAgent2D
@export var enemy_fov: EnemyFov
@export var state_machine: StateMachine

@export var drop_item: PackedScene

var dead_from_save := false

func _ready() -> void:
	if dead_from_save:
		_die()
	
	if hurtbox:
		hurtbox.died.connect(_die)


## Standard movement options to use ##

# Constant speed
func move_towards(pos: Vector2, speed: float) -> Vector2:
	return (pos - global_position).normalized() * speed

# Add speed
func accelerate_towards(pos: Vector2, speed: float) -> Vector2:
	return velocity + (pos - global_position).normalized() * speed

# Lerps from current velocity to new velocity according to drift_factor
func drift_towards(pos: Vector2, speed: float, drift_factor: float) -> Vector2:
	var new_vel = (pos - global_position).normalized() * speed
	return velocity.lerp(new_vel, drift_factor)

# Speed based on distance to target
func spring_towards(pos: Vector2, strength: float, damping: float) -> Vector2:
	var force: Vector2 = ((pos - global_position) * strength) - (velocity * damping)
	return velocity + force


# signals
func _die() -> void:
	if drop_item && !dead_from_save:
		var item: BaseItem = drop_item.instantiate()
		get_parent().add_child(item)
		item.global_position = global_position
	"""
	if attackbox:
		attackbox.queue_free()
	if state_machine && dead_state:
		state_machine.change_state(dead_state)
	else:
		queue_free()
	"""

# Other util
func get_diver_pos() -> Vector2:
	var closest_player: Diver
	var closest_squared_distance := 1000000000.0
	for player in Global.player_array:
		var dist := player.global_position.distance_squared_to(global_position)
		if dist < closest_squared_distance:
			closest_squared_distance = dist
			closest_player = player
	return closest_player.global_position
