extends BaseBullet

func fire(angle):
	rotation = angle + PI/2
	velocity = Util.angle_to_vector_radians(angle, speed)
	attackbox.is_attacking = true
