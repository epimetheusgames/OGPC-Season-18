class_name Kelp
extends Node2D

@export var length: int = 100
@export var kelp: PackedScene

@onready var rope: VerletRope = $"VerletRope"
@onready var drawer: RopeLineDrawer = $"RopeLineDrawer"

var kelp_segments: Array[KelpSegment] = []
var spawn_pos: Vector2 = Vector2(0, -8)
var sway_amplitudes: Array[float]
var segment_spacing := 1
var sway_frequency := 0.8
var base_time := 0.0

# Wait for ropelinedrawer to fill points.
var first_time := true

var waiting := true

func _ready() -> void:
	drawer.max_length = length
	
	for i in range(50):
		var new_kelp_segment: KelpSegment = kelp.instantiate()
		new_kelp_segment.scale = Vector2(3, 3)
		add_child(new_kelp_segment)
		kelp_segments.append(new_kelp_segment)
		new_kelp_segment.get_node("KelpSegment").frame = i % new_kelp_segment.segment_frames
	
	for i in range(rope.points.size()):
		if i % segment_spacing == 0:
			sway_amplitudes.append(Global.rng.randf_range(0.0, 0.2))
		else:
			sway_amplitudes.append(0.0)

func _process(delta: float) -> void:
	if first_time:
		first_time = false
		return
	
	base_time += delta
	
	rope.is_on_screen = $VisibleOnScreenNotifier2D.is_on_screen() || waiting
	
	if !rope.is_on_screen:
		return
	
	kelp_segments[0].visible = false
	kelp_segments[1].visible = false
	
	for i in range(2, drawer.points.size()):
		if i > length:
			kelp_segments[i].visible = false
			continue
		
		var kelp_segment: KelpSegment = kelp_segments[i]
		kelp_segment.position = (drawer.points[i - 1] + drawer.points[i]) / 2.0
		
		if i > 0 && i < length - 1:
			var dir := drawer.points[i - 1].direction_to(drawer.points[i])
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

func _on_smooth_out_timer_timeout() -> void:
	waiting = false
