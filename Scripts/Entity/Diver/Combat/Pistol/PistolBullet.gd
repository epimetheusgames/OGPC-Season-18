class_name PistolProjectile
extends BaseBullet


func _physics_process(delta: float) -> void:
	super(delta)

func fire(angle: float) -> void:
	rotation = angle + PI/2
	velocity = Util.angle_to_vector(angle, speed)
	print(velocity)
