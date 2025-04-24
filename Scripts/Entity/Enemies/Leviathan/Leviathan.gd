## This is a big fish enemy
# Owned by: kaitaobenson

class_name Leviathan
extends Enemy

@onready var rope: FabrikRope = $"FabrikRope"
@onready var head_segment: Node2D = $"HeadSegment"
@onready var body_segment: Node2D = $"BodySegment"

@onready var leviathan_segments: Array[Node2D] = []

func _ready() -> void:
	# Add in leviathan segments
	for i in range(rope.point_amount - 1):
		var new_segment = body_segment.duplicate()
		new_segment.z_index = rope.point_amount - i
		add_child(new_segment)
		leviathan_segments.append(new_segment)
	
	head_segment.z_index = rope.point_amount + 1
	
	body_segment.queue_free()
	
	state_machine.init(self)
	
	

func _physics_process(delta: float) -> void:
	
	var animation: AnimatedSprite2D = head_segment.get_node("AnimatedSprite2D")
	animation.play("Munch")
	
	head_segment.global_rotation = rope.points[0].angle_to_point(rope.points[1]) + PI

	for i in range(rope.point_amount - 1):
		var segment = leviathan_segments[i]
		var prev_point = rope.points[i]
		var current_point = rope.points[i + 1]
		
		segment.global_position = current_point
		segment.global_rotation = prev_point.angle_to_point(current_point) + PI
	
	if Global.is_multiplayer && has_multiplayer_sync && _is_node_owner():
		Global.godot_steam_abstraction.sync_var(rope, "points")
	
	#velocity = (get_diver_pos() - position).normalized() * 300
	state_machine.process_physics(delta)
	move_and_slide()
