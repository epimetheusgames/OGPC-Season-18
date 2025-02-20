class_name PistolProjectile
extends BaseBullet

func _physics_process(delta: float) -> void:
	super(delta)

func fire(angle: float) -> void:
	rotation = angle + PI/2
	velocity = Util.angle_to_vector_radians(angle, speed)
	attackbox.is_attacking = true

func _on_body_entered(body: Node2D) -> void:
	if body is Diver:
		return
	
	await get_tree().create_timer(0.1).timeout
	queue_free()
