class_name Kelp
extends Node2D

@export var length: int = 100

@export var kelp: PackedScene

@onready var rope: BaseRope = $"FabrikRope"

var kelp_segments: Array[KelpSegment] = []

var spawn_pos: Vector2 = Vector2(0, -8)

func _ready() -> void:
	for i in range(length):
		var new_kelp_segment: KelpSegment = kelp.instantiate()
		new_kelp_segment.scale = Vector2(5,5)
		add_child(new_kelp_segment)
		kelp_segments.append(new_kelp_segment)
	
	rope.end_pos_on = true

func _process(delta: float) -> void:
	rope.end_pos = get_global_mouse_position()
	
	for i in range(length):
		var kelp_segment: KelpSegment = kelp_segments[i]
		kelp_segment.global_position = rope.points[i]
		
		if i > 0 and i < length - 1:
			var dir := rope.points[i - 1].direction_to(rope.points[i + 1])
			kelp_segment.rotation = dir.angle() + PI/2
		elif i < length - 1:
			kelp_segment.rotation = rope.points[i].angle_to_point(rope.points[i + 1]) + PI/2
	
	
