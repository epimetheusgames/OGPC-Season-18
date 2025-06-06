## This adds and sets the tentacles on the jelly
# Owned by: kaitaobenson

class_name JellyfishTentacles
extends Node2D

@export var tentacle_data: TentacleData

@onready var jellyfish: Jellyfish = get_parent()
@onready var attackbox_polygon: CollisionPolygon2D = $"ContinuousAttack/CollisionPolygon2D"
@onready var glow_ball: PointLight2D = $"GlowBall"  # I couldn't think of a better name ;(

var ropes: Array[VerletRope] = []
var glow_balls1: Array[PointLight2D] = []
var glow_balls2: Array[PointLight2D] = []
var glow_balls3: Array[PointLight2D] = []

func _ready() -> void:
	for i in range(tentacle_data.amount):
		# ANCHOR
		var new_tentacle_anchor := Node2D.new()
		new_tentacle_anchor.name = "Anchor"
		
		add_child(new_tentacle_anchor, true)
		
		var x_pos = 0
		
		if tentacle_data.amount != 1:
			var spacing = tentacle_data.bottom_width / (tentacle_data.amount - 1)
			x_pos = (-tentacle_data.bottom_width / 2) + (i * spacing)
		
		new_tentacle_anchor.position = Vector2(x_pos, 0)
		
		# ROPE
		var new_rope := VerletRope.new()
		new_rope.component_container = get_parent().get_path()
		new_rope.name = "TentacleRope"
		new_rope.damping = 0.5
		
		new_rope.point_separation = 40
		new_rope.point_amount = round(tentacle_data.length / 40)
		
		new_rope.start_pos_on = true
		new_rope.end_pos_on = false
		new_rope.start_anchor_node = new_tentacle_anchor
		
		new_rope.iterations = 2
		
		new_tentacle_anchor.add_child(new_rope)
		ropes.append(new_rope)
		
		# LINE
		var new_line = RopeLineDrawer.new()
		new_line.name = "SmoothedLine"
		new_line.rope = new_rope
		new_line.smoothing_on = true
		new_line.default_color = tentacle_data.color
		
		# There's a weird bug with lines glowing, turn the brightness down
		new_line.modulate.r *= 0.5
		new_line.modulate.g *= 0.5
		new_line.modulate.b *= 0.5
		
		new_line.z_index = 1000
		
		new_rope.add_child(new_line)
		new_rope.rope_drawer = new_line
		
		new_rope.start_anchor_node = new_tentacle_anchor
		
		# GLOW BALL
		var gl_1 = glow_ball.duplicate()
		add_child(gl_1)
		glow_balls1.append(gl_1)
		
		var gl_2 = glow_ball.duplicate()
		add_child(gl_2)
		glow_balls2.append(gl_2)
		
		var gl_3 = glow_ball.duplicate()
		add_child(gl_3)
		glow_balls3.append(gl_3)
	
	glow_ball.queue_free()


func _physics_process(delta: float) -> void:
	var pos =  attackbox_polygon.global_position
	
	var tentacle_amount = ropes.size() - 1
	var rope_length = ropes[0].points.size() - 1
	
	var p1 = ropes[0].points[0] - pos
	var p2 = ropes[0].points[rope_length] - pos
	
	var p3 = ropes[tentacle_amount].points[0] - pos
	var p4 = ropes[tentacle_amount].points[rope_length] - pos
	
	attackbox_polygon.global_rotation = 0.0
	attackbox_polygon.polygon = [p1, p2, p4, p3]
	
	for i in range(ropes.size()):
		glow_balls1[i].global_position = ropes[i].points[2]
		glow_balls2[i].global_position = ropes[i].points[6]
		glow_balls3[i].global_position = ropes[i].points[11]


func tentacles_up(speed: float) -> void:
	_adjust_tentacle_gravity(speed * 100, 0.01)

func tentacles_down(speed: float) -> void:
	_adjust_tentacle_gravity(speed * -100, 0.0001)


func _adjust_tentacle_gravity(y_gravity: float, extra_rot_factor: float) -> void:
	for rope in ropes:
		var anchor: Node2D = rope.get_parent()
		
		var extra_rotation: float = anchor.position.x * extra_rot_factor
		var angle = jellyfish.global_rotation + PI + extra_rotation
		var raw_gravity = Vector2(0, y_gravity)
		var tentacle_gravity = raw_gravity.rotated(angle)
		
		rope.gravity = tentacle_gravity
