# Lightweight gun powered by rubbers or air canisters,
# used for spearing small / medium fish
## Owned by: kaitaobenson

class_name Speargun
extends Gun

@onready var emit_point: Node2D = $"EmitPoint"
@onready var cone_of_fire: ConeOfFire = $"EmitPoint/ConeOfFire"

@onready var hand1_point: Node2D = $"Hand1Point"
@onready var hand2_point: Node2D = $"Hand2Point"

func _process(delta: float) -> void:
	super(delta)
	
	var spread: float = 0.0
	cone_of_fire.increase_spread(spread)
	
	if gun_state == GunState.HOLDING:
		use_hand2 = false
	else:
		use_hand2 = true

func get_hand1_pos() -> Vector2:
	if flipped || gun_state == GunState.HOLDING:
		return hand1_point.global_position
	else:
		return hand2_point.global_position

func get_hand2_pos() -> Vector2:
	if flipped || gun_state == GunState.HOLDING:
		return hand2_point.global_position
	else:
		return hand1_point.global_position

func attack() -> void:
	var new_spear: Spear = bullet_scene.instantiate()
	add_child(new_spear)
	
	new_spear.global_position = emit_point.global_position
	new_spear.global_rotation = global_rotation
	
	var angle: float = cone_of_fire.get_shot_angle()
	new_spear.fire(angle)
	"""
	var new_rope := VerletRope.new()
	new_rope.component_container = self.get_path()
	new_rope.start_pos_on = true
	new_rope.start_anchor_node = emit_point
	new_rope.end_pos_on = true
	new_rope.end_anchor_node = new_spear.rope_point
	
	add_child(new_rope)
	
	var new_rope_drawer := RopeLineDrawer.new()
	add_child(new_rope_drawer)
	new_rope_drawer.rope = new_rope
	"""
	#print_tree_pretty()
