class_name PistolProjectile
extends BaseBullet


func _ready():
	set_damage($AttackBoxComponent.damage)

func _on_area_entered(area: Area2D) -> void:
	if area.get_parent() is Enemy:
		var parent := area.get_parent() as Enemy
		get_parent().remove_child(self)
		parent.add_child(self)
		await get_tree().create_timer(2).timeout
		$AttackBoxComponent.attack()
