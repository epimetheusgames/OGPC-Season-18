## Diver combat system.
class_name DiverCombat
extends Node2D

@onready var knife: Node2D = $"knife"

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		attack()

func attack() -> void:
	$AttackBoxComponent.attack()

func shoot() -> void:
	var new_bullet: BaseBullet = load("res://Scenes/TSCN/Objects/BaseBullet.tscn").instantiate()
	new_bullet.top_level = true
	new_bullet.global_position = global_position
	new_bullet.rotation = global_position.angle_to_point(get_global_mouse_position())
	new_bullet.set_velocity(Util.angle_to_vector(new_bullet.rotation, 20))
	add_child(new_bullet)
	
	var new_rope := FabrikRopeComponent.new()
	new_rope.top_level = true
	new_rope.start_anchor_node = new_bullet
	new_rope.end_anchor_node = self
	new_rope.length = 200
	add_child(new_rope)
