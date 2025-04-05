class_name ArrowFish
extends CharacterBody2D


@export var hurtbox: Hurtbox
@export var nav_agent: NavigationAgent2D
@export var enemy_fov: EnemyFov

@export var drop_item: BaseItem

enum EnemyState {
	WANDER,
	AIM,
	DASH,
	CHASE,
	ESCAPE,
}

var enemy_state: EnemyState = EnemyState.WANDER

var wander_anchor: Vector2
var wander_radius: float = 500.0
var wander_speed: float = 4.0
var wander_timer: Timer = Timer.new()
var wander_target_pos: Vector2

var aim_timer: float = 0.0

var dash_spring_strength: float = 10.0
var dash_spring_damping: float = 0.1
var dash_timer: float = 0.0

var chase_speed: float = 10.0

var escape_speed: float = 500
var escape_angle_variation: float = 25  # Degrees
var escape_toggle: bool = true
var escape_target_pos: Vector2

var diver_pos: Vector2
var delta: float

func _ready() -> void:
	# Set up wander
	wander_anchor = global_position
	
	wander_timer.wait_time = 0.5
	wander_timer.one_shot = false
	wander_timer.timeout.connect(_update_wander_position)
	
	add_child(wander_timer)
	wander_timer.start()
	
	# Set up escape
	wander_timer.timeout.connect(_update_escape_position)
	
	
	hurtbox.damaged.connect(_on_take_damage)
	hurtbox.died.connect(_on_death)

func _on_take_damage(_amount: float, _by: Attackbox):
	print("ARROWFISH DAMAGED, HELTH: " + str(hurtbox.health))

func _on_death():
	print("Arrowfish died ;(")
	queue_free()

func _physics_process(delta: float) -> void:
	diver_pos = Global.player.global_position
	
	match enemy_state:
		EnemyState.WANDER:
			wander(delta)
			if enemy_fov.can_see_point(diver_pos):
				enemy_state = EnemyState.AIM
			print("WANDER")
		
		EnemyState.AIM:
			aim(delta)
			
			aim_timer += delta
			if aim_timer >= 5.0:
				enemy_state = EnemyState.DASH
				aim_timer = 0.0
			print("AIM")
		
		EnemyState.DASH:
			dash(delta)
			
			dash_timer += delta
			if dash_timer >= 1.0:
				enemy_state = EnemyState.CHASE
				dash_timer = 0.0
			
			print("DASH")
		
		EnemyState.CHASE:
			chase(delta)
			
			if hurtbox.health < 30:
				enemy_state = EnemyState.ESCAPE
			elif !enemy_fov.can_see_point(diver_pos):
				enemy_state = EnemyState.WANDER
			print("CHASE")
		
		EnemyState.ESCAPE:
			escape(delta)
			if global_position.distance_to(diver_pos) > 800:
				enemy_state = EnemyState.WANDER
			print("ESCAPE")
	
	velocity *= 0.99
	move_and_slide()

func _update_wander_position() -> void:
	wander_target_pos = get_random_point_in_circle(wander_anchor, wander_radius)

func wander(delta: float) -> void:
	nav_agent.target_position = wander_target_pos
	print(wander_target_pos)
	var next_path_pos = nav_agent.get_next_path_position()
	
	drive_towards(next_path_pos, wander_speed, delta)

func aim(delta: float) -> void:
	rotation = lerp_angle(
		rotation,
		global_position.angle_to_point(diver_pos),
		4.0 * delta
	)

func dash(delta: float) -> void:
	spring_towards(diver_pos, dash_spring_strength, dash_spring_damping, delta)

func chase(delta: float) -> void:
	nav_agent.target_position = diver_pos
	
	var next_path_pos = nav_agent.get_next_path_position()
	drive_towards(next_path_pos, chase_speed, delta)

func _update_escape_position() -> void:
	var escape_angle: float = (global_position - diver_pos).angle()
	
	if escape_toggle:
		escape_toggle = false
		escape_angle += deg_to_rad(escape_angle_variation)
	else:
		escape_toggle = true
		escape_angle -= deg_to_rad(escape_angle_variation)
	
	
	escape_target_pos = global_position + Util.angle_to_vector_radians(escape_angle, 1000)


func escape(delta: float) -> void:
	nav_agent.target_position = escape_target_pos
	var escape_pos = nav_agent.get_next_path_position()
	
	move_towards(escape_pos, escape_speed, delta)



##-__________________________-______-_- Stuff


func spring_towards(pos: Vector2, spring_strength: float, spring_damping: float, delta: float) -> void:
	var force: Vector2 = ((pos - global_position) * spring_strength) - (velocity * spring_damping)
	velocity += force * delta
	
	if velocity.length() > 0.1:
		rotation = velocity.angle()


func drive_towards(pos: Vector2, speed: float, delta: float) -> void:
	velocity += (pos - global_position).normalized() * speed
	
	if velocity.length() > 0.1:
		rotation = velocity.angle()


func move_towards(pos: Vector2, speed: float, delta: float) -> void:
	velocity = (pos - global_position).normalized() * speed
	print(velocity)
	if velocity.length() > 0.1:
		rotation = velocity.angle()


static func get_random_point_in_circle(circle_pos: Vector2, circle_radius: float) -> Vector2:
	while true:
		var rand_pos: Vector2 = Vector2(
			randi_range(circle_pos.x - circle_radius, circle_pos.x + circle_radius),
			randi_range(circle_pos.y - circle_radius, circle_pos.y + circle_radius)
		)
		
		if circle_pos.distance_to(rand_pos) <= circle_radius:
			return rand_pos
	
	return Vector2.ZERO # Shouldn't happen
