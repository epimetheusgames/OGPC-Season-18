class_name PistolProjectile
extends BaseBullet

@onready var buoyancy: BuoyancyComponent = $"BuoyancyComponent"

func _process(delta: float) -> void:
	# TODO: This is really bad, fix this whole goddamn function at some point.
	if !get_node_or_null("../../../Level/Waves"):
		return
	buoyancy.waves = get_node("../../../Level/Waves")
	
	if get_parent() is RigidBody2D:
		if buoyancy.is_in_air:
			get_parent().linear_damp = 0
		else:
			get_parent().linear_damp = 3
"""
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
"""
