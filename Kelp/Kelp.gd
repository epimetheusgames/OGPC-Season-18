class_name Kelp
extends Node2D

@export var length: int = 100
@export var kelp: PackedScene

@onready var rope: BaseRope = $"VerletRope"
@onready var drawer: RopeLineDrawer = $"RopeLineDrawer"

var kelp_segments: Array[KelpSegment] = []
var spawn_pos: Vector2 = Vector2(0, -8)
var sway_amplitudes: Array[float]
var segment_spacing := 1  # sway every 15th point
var sway_frequency := 0.8
var base_time := 0.0

# Wait for ropelinedrawer to fill points.
var first_time := true

func _ready() -> void:
	for i in range(length):
		var new_kelp_segment: KelpSegment = kelp.instantiate()
		new_kelp_segment.scale = Vector2(5,5)
		add_child(new_kelp_segment)
		kelp_segments.append(new_kelp_segment)
	
	for i in range(rope.points.size()):
		if i % segment_spacing == 0:
			sway_amplitudes.append(Global.rng.randf_range(0.0, 0.2))
		else:
			sway_amplitudes.append(0.0)

func _process(delta: float) -> void:
	if !$VisibleOnScreenNotifier2D.is_on_screen():
		return
	
	if first_time:
		first_time = false
		return
	
	base_time += delta
	
	for i in range(length - 1):
		var kelp_segment: KelpSegment = kelp_segments[i]
		kelp_segment.global_position = (drawer.points[i] + drawer.points[i + 1]) / 2.0
		
		if i > 0 && i < length - 1:
			var dir := drawer.points[i - 1].direction_to(drawer.points[i + 1])
			kelp_segment.rotation = dir.angle() + PI/2
		elif i < length - 1:
			kelp_segment.rotation = drawer.points[i].angle_to_point(drawer.points[i + 1]) + PI/2
	
	for i in range(rope.points.size()):
		rope.points[i].y -= 0.2 * delta * 60
		var sway_amount := sway_amplitudes[i]
		if sway_amount > 0.0:
			var phase := i * 1 + Global.rng.randf_range(-0.7, 0.7)
			var sway := sin(base_time * sway_frequency + phase) * sway_amount + Global.rng.randf_range(-0.3, 0.3)
			rope.points[i].x += sway
	
