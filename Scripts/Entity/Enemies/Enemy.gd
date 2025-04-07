## Base class for all enemies
# Owned by: kaibenson

class_name Enemy
extends Entity

@export var hurtbox: Hurtbox
@export var attackbox: Attackbox
@export var animations: AnimatedSprite2D
@export var nav_agent: NavigationAgent2D
@export var enemy_fov: EnemyFov
@export var attack_dist: float
@export var dead_state: State
@export var state_machine: StateMachine

@export var drop_item: PackedScene

func _ready() -> void:
	if hurtbox:
		hurtbox.died.connect(_die)

func _process(delta: float) -> void:
	if attackbox:
		attackbox.detect_and_damage_hurtboxes()

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
	#print(velocity)
	if velocity.length() > 0.1:
		rotation = velocity.angle()

# signals
func _die() -> void:
	if drop_item:
		var item: BaseItem = drop_item.instantiate()
		get_parent().add_child(item)
		item.global_position = global_position
	if hurtbox:
		hurtbox.queue_free()
	if state_machine && dead_state:
		state_machine.change_state(dead_state)
	else:
		queue_free()

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
