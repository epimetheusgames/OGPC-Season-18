# Lightweight gun powered by rubbers or air canisters,
# used for spearing small / medium fish
## Owned by: kaitaobenson

class_name Speargun
extends Gun

@onready var emit_point: Node2D = $"EmitPoint"
@onready var gun_sprite: Sprite2D = $"GunSprite"  # TODO: replace with animated node2D 

func _process(delta: float) -> void:
	super(delta)
	global_position = get_gun_position()
	global_rotation = get_gun_rotation()

func get_gun_position() -> Vector2:
	return hand1_pos

func get_gun_rotation() -> float:
	var mouse_pos: Vector2 = get_global_mouse_position()
	return hand1_pos.angle_to_point(mouse_pos)

func attack() -> void:
	var new_spear: Spear = bullet_scene.instantiate()
	add_child(new_spear)
	
	new_spear.global_position = emit_point.global_position
	new_spear.global_rotation = global_rotation
	
	var angle: float = global_position.angle_to_point(mouse_pos)
	new_spear.fire(angle)
	
	var new_rope := VerletRope.new()
	new_rope.component_container = self.get_path()
	new_rope.start_pos_on = true
	new_rope.start_anchor_node = emit_point
	new_rope.end_pos_on = true
	new_rope.end_anchor_node = new_spear.rope_point
	print(new_rope.end_anchor_node)
	
	add_child(new_rope)
	
	var new_rope_drawer := RopeLineDrawer.new()
	add_child(new_rope_drawer)
	new_rope_drawer.rope = new_rope
	
	#print_tree_pretty()
