extends SubmarineWeapon

@export var time_between_bursts := 0.3

func fire():
	for i in range(3):
		var bullet : BaseBullet = projectile_scene.instantiate()
		add_child(bullet)
		bullet.fire(self.global_rotation)
		await get_tree().create_timer(time_between_bursts).timeout
