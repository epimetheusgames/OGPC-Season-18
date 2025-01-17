## This rope uses Verlet Integration to more accurately simulate
## ropes.  Collision is super jank
# Owned by: kaitaobenson

class_name VerletRope
extends BaseRope

const TIMESTEP: float = 0.1

@export var iterations: int = 2

@export var gravity: Vector2 = Vector2(0, 100)
@export var damping: float = 0.98  # 1 = no damping, < 1 slows movement
@export var enable_collisions: bool = true

var verlet_nodes: Array[VerletNode]
var raycast_query: PhysicsRayQueryParameters2D
var is_on_screen := true
var rope_drawer: RopeLineDrawer
var normals: Array[Vector2]

func _ready() -> void:
	super()
	component_name = "VerletRope"
	
	raycast_query = PhysicsRayQueryParameters2D.new()
	
	var spawn_pos: Vector2 = get_node(component_container).global_position if component_container else Vector2.ZERO
	
	verlet_nodes.resize(point_amount)
	for i in range(point_amount):
		verlet_nodes[i] = VerletNode.new()
		verlet_nodes[i].set_up(spawn_pos) 
	
	normals.resize(point_amount)

func _process(delta: float) -> void:
	super(delta)
	
	if !is_on_screen:
		return
	
	# quick fix
	if start_anchor_node:
		# quick fix
		start_pos = start_anchor_node.global_position
	if end_anchor_node:
		end_pos = end_anchor_node.global_position
	
	simulate(delta)  # Simulate Verlet integration
	
	for i in range(iterations):
		apply_constraints()  # Apply constraints and resolve collisions
	
	for i in range(verlet_nodes.size()):
		points[i] = verlet_nodes[i].position
		
	if rope_drawer:
		rope_drawer.points = points

func simulate(delta: float):
	for i in range(point_amount):
		var node: VerletNode = verlet_nodes[i]
		var temp: Vector2 = node.position
		
		# Calculate velocity, applying damping to slow down the points
		var velocity: Vector2 = (node.position - node.old_position) * damping + (gravity * TIMESTEP * TIMESTEP * delta * 60)
		
		# Iteratively resolve collisions or simply move the node if collisions are disabled
		var resolved_position = node.position
		for j in range(3):  # Apply multiple iterations of collision resolution
			if enable_collisions:
				resolved_position += collide_and_translate(resolved_position, velocity / 3, i)  # Divide motion for each iteration
			else:
				# Just move freely if collisions are disabled
				resolved_position += (velocity) * delta * 60
		
		node.position = resolved_position
		
		# Update the previous position for the next step
		node.old_position = temp

# Apply constraints such as anchor positions and node separation
func apply_constraints():
	# Pull toward anchors, and keep node distance constraints
	if start_pos_on:
		verlet_nodes[0].position = start_pos
	if end_pos_on:
		verlet_nodes[point_amount - 1].position = end_pos
	
	for i in range(point_amount - 1):
		var node_1: VerletNode = verlet_nodes[i]
		var node_2: VerletNode = verlet_nodes[i + 1]
		
		var direction: Vector2 = node_2.position - node_1.position
		var distance: float = direction.length()
		
		if distance == 0:
			continue
		
		direction = direction.normalized()
		var difference_factor: float = point_separation - distance
		var translate: Vector2 = direction * difference_factor * 0.5  # Split the difference equally
		
		var final_translate_1: Vector2
		var final_translate_2: Vector2 
		
		# Apply translation with collision handling or simply move if collisions are disabled
		if enable_collisions:
			final_translate_1 = collide_and_translate(node_1.position, -translate, i)
			final_translate_2 = collide_and_translate(node_2.position, translate, i + 1)
		else:
			final_translate_1 = -translate
			final_translate_2 = translate
		
		node_1.position += final_translate_1
		node_2.position += final_translate_2
		
	if enable_collisions:
		for i in range(point_amount - 1):
			var out := resolve_spikes(verlet_nodes[i].position, verlet_nodes[i + 1].position)
			verlet_nodes[i].position += (out[0] - verlet_nodes[i].position).normalized() * 2
			verlet_nodes[i + 1].position += (out[1] - verlet_nodes[i + 1].position).normalized() * 2

# Spike resolution (one node is on one side and the other is on the other side)
func resolve_spikes(node1: Vector2, node2: Vector2) -> Array[Vector2]:
	raycast_query.from = node1
	raycast_query.to = node2
	raycast_query.collide_with_bodies = true
	
	var world: World2D = Global.get_world_2d()
	var result: Dictionary = world.direct_space_state.intersect_ray(raycast_query)
	
	if !result:
		return [node1, node2]
	
	if result["collider"] is Diver:
		return [node1, node2]
	
	var pos1: Vector2 = result.position
	var normal1: Vector2 = result.normal
	var aligned1: Vector2 = normal1.rotated(PI / 2) # Rotate 90 degrees to align with edge.
	
	raycast_query.from = node2
	raycast_query.to = node1
	result = world.direct_space_state.intersect_ray(raycast_query)
	
	if !result:
		return [node1, node2]
	
	var pos2: Vector2 = result.position
	var normal2: Vector2 = result.normal
	var aligned2: Vector2 = normal2.rotated(PI / 2)
	
	var intersection_point = Geometry2D.line_intersects_line(pos1, aligned1, pos2, aligned2)
	if !intersection_point:
		# Just being careful.
		intersection_point = Geometry2D.line_intersects_line(pos1, -aligned1, pos2, -aligned2)
		
		# Lines are parallel. Womp womp.
		if !intersection_point:
			return [node1, node2]
	
	return [intersection_point, intersection_point]

# Collision resolution (with option to disable it)
func collide_and_translate(origin: Vector2, motion: Vector2, index: int) -> Vector2:
	# If collisions are disabled, just move as normal
	if not enable_collisions or motion.is_zero_approx():
		return motion
	
	if !component_container:
		print("ERROR: Verlet rope at path " + str(get_path()) + " needs a component container to do physics!")
		return motion
		
	raycast_query.from = origin
	raycast_query.to = origin + motion
	raycast_query.collide_with_bodies = true
	
	var world2d: World2D = Global.get_world_2d()
	var result: Dictionary = world2d.direct_space_state.intersect_ray(raycast_query)
	
	if not result:
		# No collision detected, move as normal
		return motion
	
	if result["collider"] is Diver:
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


class VerletNode:
	const STEP_TIME: float = 0.01
	
	var position: Vector2
	var old_position: Vector2
	
	func set_up(position: Vector2):
		self.position = position
		self.old_position = position
