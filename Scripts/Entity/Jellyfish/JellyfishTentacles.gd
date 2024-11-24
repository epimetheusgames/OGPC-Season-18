class_name JellyfishTentacles
extends Node2D

@export var tentacles: Array[Tentacles] = []

@onready var jellyfish: Jellyfish = get_parent()

var boosting: bool = false
var is_on_screen := false
var ropes: Array[VerletRopeComponent] = []
@export var on_screen_notifier: VisibleOnScreenNotifier2D

func _ready() -> void:
	for tentacle in tentacles: 
		add_tentacle(tentacle)

func add_tentacle(tentacle_data: Tentacles) -> void:
	for i in range(tentacle_data.amount):
		var new_tentacle_anchor := Node2D.new()
		new_tentacle_anchor.name = "Anchor"
		
		var spacing = tentacle_data.bottom_width / (tentacle_data.amount - 1)
		var x_pos = (-tentacle_data.bottom_width / 2) + (i * spacing) + randf_range(-spacing * 0.1, spacing * 0.1)
		
		new_tentacle_anchor.position = Vector2(x_pos, 0)
		
		var new_rope := VerletRopeComponent.new()
		new_rope.name = "TentacleRope"
		new_rope.enable_collisions = false
		new_rope.damping = 0.5
		
		new_rope.nodes_separation = 40
		new_rope.nodes_amount = round(tentacle_data.length / 40)
		
		var new_line = Line2D.new()
		new_line.name = "SmoothedLine"
		new_line.visible = false
		
		var new_smoothed_line := Line2D.new()
		new_smoothed_line.name = "SmoothedLine"
		new_smoothed_line.default_color = tentacle_data.color
		new_smoothed_line.width = tentacle_data.thickness
		
		add_child(new_tentacle_anchor, true)
		
		new_tentacle_anchor.add_child(new_rope)
		ropes.append(new_rope)
		
		new_rope.add_child(new_line)
		new_rope.add_child(new_smoothed_line)
		
		new_rope.start_anchor_node = new_tentacle_anchor
		new_rope.line = new_line
		new_rope.smoothed_line = new_smoothed_line

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
	for rope in ropes:
		rope.is_on_screen = on_screen_notifier.is_on_screen()
		
	if not boosting:
		var tentacle_gravity: Vector2 = Vector2(0, 50)
		tentacle_gravity = tentacle_gravity.rotated(jellyfish.global_rotation)
		
		for rope in ropes:
			rope.gravity = tentacle_gravity
