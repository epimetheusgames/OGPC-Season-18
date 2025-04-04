class_name ArrowFish
extends Enemy

var wander_radius: float = 1000.0
var wander_timer: Timer = Timer.new()
var wander_pos: Vector2

var starting_pos: Vector2


func _ready() -> void:
	starting_pos = global_position
	
	add_child(wander_timer)
	
	wander_timer.wait_time = 1.0
	wander_timer.one_shot = false
	wander_timer.timeout.connect(_update_wander_position)
	
	wander_timer.start()
	
	hurtbox.damaged.connect(_on_take_damage)
	hurtbox.died.connect(_on_death)

func _on_take_damage(_amount: float, _by: Attackbox):
	print("ARROWFISH DAMAGED, HELTH: " + str(hurtbox.health))

func _on_death():
	print("Arrowfish died ;(")
	queue_free()

func _physics_process(delta: float) -> void:
	# Code for choosing which state to be in here
	enemy_state = ENEMY_STATE.WANDER
	
	print(enemy_fov.can_see_point(get_global_mouse_position()))
	
	#_call_movement(delta)
	velocity *= 0.99
	move_and_slide()

func _update_wander_position() -> void:
	wander_pos = get_random_point_in_circle(starting_pos, wander_radius)

func wander(delta: float) -> void:
	nav_agent.target_position = wander_pos
	var next_path_pos = nav_agent.get_next_path_position()
	
	move_towards(next_path_pos, 5)

func chase(delta: float) -> void:
	# player required
	nav_agent.target_position = Global.player.global_position
	
	var next_path_pos = nav_agent.get_next_path_position()
	move_towards(next_path_pos, 5)

func escape(delta: float) -> void:
	# player required
	nav_agent.target_position = global_position + (global_position - Global.player.global_position).normalized() * 1000
	
	var escape_pos = nav_agent.get_next_path_position()
	
	move_towards(escape_pos, 5)

func move_towards(pos: Vector2, speed: float) -> void:
	velocity += (pos - global_position).normalized() * speed
	if velocity.length() != 0:
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
