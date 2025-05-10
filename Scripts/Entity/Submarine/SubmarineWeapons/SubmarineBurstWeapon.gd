# Coded by Xavier
## Three-shot burst-fire canon for submarine

class_name SubmarineBurstWeapon
extends SubmarineWeapon

@export var time_between_bursts := 0.3
@export var bursts : int = 3

@onready var sprite : AnimatedSprite2D = get_node("Barrel")

func fire():
	for i in range(bursts):
		sprite.play("Shoot")
		heat += heat_increase_per_shot/bursts
		var bullet : BaseBullet = projectile_scene.instantiate()
		add_child(bullet)
		bullet.global_position = emission_point.global_position
		bullet.fire(self.global_rotation)
		await get_tree().create_timer(time_between_bursts).timeout
	sprite.frame = 0
