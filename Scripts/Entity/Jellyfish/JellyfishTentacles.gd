## This adds and sets the tentacles on the jelly
# Owned by: kaitaobenson

class_name JellyfishTentacles
extends Node2D

@export var tentacles: Array[Tentacles] = []

@onready var jellyfish: Jellyfish = get_parent()

var boosting: bool = false
var is_on_screen := false
var ropes: Array[VerletRope] = []
@export var on_screen_notifier: VisibleOnScreenNotifier2D

func _ready() -> void:
	for tentacle in tentacles: 
		add_tentacle(tentacle)

func add_tentacle(tentacle_data: Tentacles) -> void:
	for i in range(tentacle_data.amount):
		# ANCHOR
		var new_tentacle_anchor := Node2D.new()
		new_tentacle_anchor.name = "Anchor"
		
		add_child(new_tentacle_anchor, true)
		
		# ROPE
		var spacing = tentacle_data.bottom_width / (tentacle_data.amount - 1)
		var x_pos = (-tentacle_data.bottom_width / 2) + (i * spacing) + randf_range(-spacing * 0.1, spacing * 0.1)
		
		new_tentacle_anchor.position = Vector2(x_pos, 0)
		
		var new_rope := VerletRope.new()
		new_rope.name = "TentacleRope"
		new_rope.enable_collisions = false
		new_rope.damping = 0.5
		
		new_rope.point_separation = 40
		new_rope.point_amount = round(tentacle_data.length / 40)
		
		new_tentacle_anchor.add_child(new_rope)
		ropes.append(new_rope)
		
		# LINE
		var new_line = RopeLineDrawer.new()
		new_line.name = "SmoothedLine"
		new_line.rope = new_rope
		new_line.smoothing_on = true
		
		new_rope.add_child(new_line)
		
		new_rope.start_anchor_node = new_tentacle_anchor

func boost(speed: float) -> void:
	boosting = true
	
	for rope in ropes:
		var anchor: Node2D = rope.get_parent()  # Rope's parent is the anchor
		if anchor:
			var extra_rotation: float = anchor.position.x * 0.01
			
			var tentacle_gravity: Vector2 = Vector2(0, 100)
			tentacle_gravity = tentacle_gravity.rotated(jellyfish.global_rotation + PI + extra_rotation)
			
			rope.gravity = tentacle_gravity
	
	await get_tree().create_timer(1.5).timeout
	boosting = false

func _process(delta: float) -> void:
	if not boosting:
		var tentacle_gravity: Vector2 = Vector2(0, 50)
		tentacle_gravity = tentacle_gravity.rotated(jellyfish.global_rotation)
		
		for rope in ropes:
			rope.gravity = tentacle_gravity
