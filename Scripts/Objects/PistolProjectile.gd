class_name PistolProjectile
extends BaseBullet

func _ready():
	set_damage($AttackBoxComponent.damage)
	set_velocity(Vector2.ZERO)

func _on_area_entered(area: Area2D) -> void:
	if area.get_parent() is Enemy:
		var parent := area.get_parent() as Enemy
		var previous_position = global_position
		get_parent().remove_child(self)
		parent.add_child(self)
		set_velocity(Vector2.ZERO)
		global_position = previous_position
		await get_tree().create_timer(2).timeout
		$AttackBoxComponent.attack()
		visible = false
		await get_tree().create_timer(1).timeout
		queue_free()
