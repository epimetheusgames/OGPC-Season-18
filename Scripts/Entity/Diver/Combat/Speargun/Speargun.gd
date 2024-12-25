# Lightweight gun powered by rubbers or air canisters,
# used for spearing small / medium fish
## Owned by: kaitaobenson

class_name Speargun
extends Gun

@onready var emit_point: Node2D = $"EmitPoint"
@onready var gun_sprite: Sprite2D = $"GunSprite"  # TODO: replace with animated node2D 

func _process(delta: float) -> void:
	hand1_pos = Vector2(500, 500)
	global_position = get_gun_position()
	global_rotation = get_gun_rotation()
	
	if Input.is_action_just_pressed("attack"):
		attack()  # i will remove this

func get_gun_position() -> Vector2:
	return hand1_pos

func get_gun_rotation() -> float:
	var mouse_pos: Vector2 = get_global_mouse_position()
	return hand1_pos.angle_to_point(mouse_pos)

func attack() -> void:
	var new_bullet: Spear = bullet_scene.instantiate()
	
	new_bullet.top_level = true
	new_bullet.global_position = emit_point.global_position
	new_bullet.global_rotation = rotation
	
	add_child(new_bullet)
	new_bullet.move_forwards(1000)
