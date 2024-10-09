class_name Diver

extends CharacterBody2D

@onready var diver_movement: DiverMovement = $"Movement"
@onready var diver_animation: DiverAnimation = $"Animation"
@onready var diver_combat: DiverCombat = $"Combat"
@onready var diver_flashlight: DiverFlashlight = $"Flashlight"

func _physics_process(delta: float):
	velocity = diver_movement.get_velocity()
	
	var target_angle: float = velocity.angle() + PI/2
	rotation += angle_difference(rotation, target_angle) * 0.1
	
	move_and_slide()
	
	if Input.is_action_just_pressed("shoot"):
		shoot()

func get_diver_movement() -> DiverMovement:
	return diver_movement


func shoot():
	var new_bullet: BaseBullet = load("res://Scenes/TSCN/Objects/BaseBullet.tscn").instantiate()
	new_bullet.top_level = true
	new_bullet.global_position = global_position
	new_bullet.rotation = global_position.angle_to_point(get_global_mouse_position())
	new_bullet.set_velocity(Util.angle_to_vector(new_bullet.rotation, 20))
	add_child(new_bullet)
	
	var new_rope: Rope = Rope.new()
	new_rope.start_anchor_node = new_bullet
	new_rope.end_anchor_node = self
	new_rope.length = 200
	add_child(new_rope)
