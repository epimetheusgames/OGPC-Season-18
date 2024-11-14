# Lightweight gun powered by rubbers or air canisters,
# used for spearing small / medium fish
class_name Speargun
extends Weapon
"""
@onready var spear: Spear = $"Spear"

@onready var reel_line: VerletRopeComponent = $"ReelLine"
@onready var reel_line_anchor: Node2D = $"ReelLineAnchor"

func _ready() -> void:
	reel_line.start_anchor = true
	reel_line.end_anchor = true
	
	reel_line.visible = false

func _process(delta: float) -> void:
	global_position = hand1
	
	#var target_rot: float = hand1.angle_to_point(hand2)
	#global_rotation += (target_rot - global_rotation) * 0.1
	
	global_rotation = global_position.angle_to_point(get_global_mouse_position())
	
	reel_line.start_anchor_pos = reel_line_anchor.global_position
	reel_line.end_anchor_pos = spear.global_position
	
	if Input.is_action_pressed("attack"):
		attack()


# Override
func attack() -> void:
	reel_line.visible = true
	spear.move_forwards(1000)
	
	#var tween := get_tree().create_tween()
	#reel_line.nodes_amount = 5
	#tween.tween_property(reel_line, "nodes_amount", 20, 5)
"""
