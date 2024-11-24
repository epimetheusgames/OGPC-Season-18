class_name VerletRopeComponent
extends Node2D

@export var iterations: int = 10
@export var nodes_amount: int = 30
@export var nodes_separation: float = 133

@export var gravity: Vector2 = Vector2(0, 100)
@export var damping: float = 0.98  # 1 = no damping, < 1 slows movement
@export var enable_collisions: bool = true 

@export var line: Line2D
@export var smoothed_line: Line2D

var nodes: Array[VerletNode] = []

var start_anchor_node: Node2D
var end_anchor_node: Node2D
var is_on_screen := true

const timestep: float = 0.1

var raycast_query: PhysicsRayQueryParameters2D

func _ready() -> void:
	top_level = true
	
	raycast_query = PhysicsRayQueryParameters2D.new()
	
	var spawn_pos: Vector2
	if start_anchor_node:
		spawn_pos = start_anchor_node.global_position
	
	for i in range(nodes_amount):
		nodes.append(VerletNode.new())
		nodes[i].set_up(spawn_pos)
		
		spawn_pos += Vector2(0, nodes_separation)

func _process(delta: float) -> void:
	if !line:
		return
	
	if !is_on_screen:
		if smoothed_line:
			smoothed_line.visible = false
		line.visible = false
		return
	
	if smoothed_line:
		smoothed_line.visible = true
	else:
		line.visible = true
	
	# Simulate Verlet integration
	simulate()
	
	# Apply constraints and resolve collisions
	for i in range(iterations):
		apply_constraints()
	
	# Update the visual representation of the rope
	update_line()


# Simulate Verlet integration
func simulate():
	for i in range(nodes_amount):
		var node: VerletNode = nodes[i]
		var temp: Vector2 = node.position
		
		# Calculate velocity, applying damping to slow down the points
		var velocity: Vector2 = (node.position - node.old_position) * damping + gravity * timestep * timestep
		
		# Iteratively resolve collisions or simply move the node if collisions are disabled
		var resolved_position = node.position
		for j in range(3):  # Apply multiple iterations of collision resolution
			if enable_collisions:
				resolved_position += collide_and_translate(resolved_position, velocity / 3)  # Divide motion for each iteration
			else:
				# Just move freely if collisions are disabled
				resolved_position += velocity / 3
		
		node.position = resolved_position
		
		# Update the previous position for the next step
		node.old_position = temp


# Apply constraints such as anchor positions and node separation
func apply_constraints():
	# Pull toward anchors, and keep node distance constraints
	if start_anchor_node:
		nodes[0].position = start_anchor_node.global_position
	if end_anchor_node:
		nodes[nodes_amount - 1].position = end_anchor_node.global_position

	# Apply node-to-node constraints
	for i in range(nodes_amount - 1):
		var node_1: VerletNode = nodes[i]
		var node_2: VerletNode = nodes[i + 1]
		
		var direction: Vector2 = node_2.position - node_1.position
		var distance: float = direction.length()
		
		if distance == 0:
			continue
		
		direction = direction.normalized()
		var difference_factor: float = nodes_separation - distance
		var translate: Vector2 = direction * difference_factor * 0.5  # Split the difference equally
		
		var final_translate_1: Vector2
		var final_translate_2: Vector2 
		
		# Apply translation with collision handling or simply move if collisions are disabled
		if enable_collisions:
			final_translate_1 = collide_and_translate(node_1.position, -translate)
			final_translate_2 = collide_and_translate(node_2.position, translate)
		else:
			final_translate_1 = -translate
			final_translate_2 = translate
		
		node_1.position += final_translate_1
		node_2.position += final_translate_2


# Collision resolution (with option to disable it)
func collide_and_translate(origin: Vector2, motion: Vector2) -> Vector2:
	# If collisions are disabled, just move as normal
	if not enable_collisions or motion.is_zero_approx():
		return motion
		
	raycast_query.from = origin
	raycast_query.to = origin + motion
	raycast_query.collide_with_areas = true
	raycast_query.collide_with_bodies = true
	
	var result: Dictionary = get_world_2d().direct_space_state.intersect_ray(raycast_query)
	
	if not result:
		# No collision detected, move as normal
		return motion
	
	# Collision detected: calculate how much we can move up to the collision point
	var collision_position: Vector2 = result.position
	var collision_normal: Vector2 = result.normal
	
	# Step 1: Stop at the collision point
	var adjusted_motion: Vector2 = (collision_position - origin).limit_length(motion.length())
	
	# Step 2: Calculate penetration and project back to fully resolve
	var penetration_depth: float = motion.length() - adjusted_motion.length()
	if penetration_depth > 0:
		# Push the node back along the normal to resolve penetration
		adjusted_motion += collision_normal * penetration_depth
	
	# Step 3: Allow some sliding along the surface
	if collision_normal != Vector2.ZERO:
		var remaining_motion: Vector2 = motion.slide(collision_normal)
		
		# Step 4: Combine both adjustments (stopping and sliding) with stronger correction
		return adjusted_motion + remaining_motion * 1  # Increased sliding damping
	return adjusted_motion

# Generate a cubic hermite spline based on the rope we've already calculated.
func smooth_line():
	if !smoothed_line:
		return
	
	var resoulution_multiplier: float = 4
	var new_smoothed_points: PackedVector2Array = []
	var tangents: PackedVector2Array = []
	
	# Generate tangents ... This is making it a catmull-rom spline.
	# https://en.wikipedia.org/wiki/Cubic_Hermite_spline, Catmull-Rom section.
	for i in range(1, len(line.points) - 1):
		tangents.append((line.points[i + 1] - line.points[i - 1]) / 2.0)
	
	for i in range(1, len(line.points) - 3):
		for big_t in range(0, resoulution_multiplier):
			var t = big_t / resoulution_multiplier
			
			# Massive polynomial, who knows what it means.
			var pos = ((2 * t ** 3) - (3 * t ** 2) + 1) * line.points[i] + \
					  ((t ** 3) - (2 * t ** 2) + t) * tangents[i - 1] + \
					  ((-2 * t ** 3) + (3 * t ** 2)) * line.points[i + 1] + \
					  ((t ** 3) - (t ** 2)) * tangents[i]
			
			new_smoothed_points.append(pos)
	
	smoothed_line.points = new_smoothed_points

# Update the visual line2d
func update_line():
	var display_nodes: PackedVector2Array = []
	for node: VerletNode in nodes:
		display_nodes.append(node.position)
	
	line.points = display_nodes
	smooth_line()


class VerletNode:
	const STEP_TIME: float = 0.01
	
	var position: Vector2
	var old_position: Vector2
	
	func set_up(position: Vector2):
		self.position = position
		self.old_position = position
