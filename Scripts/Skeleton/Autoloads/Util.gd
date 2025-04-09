## Utility class, only static methods should be here.

class_name Util

# -- Enums --

## Higher level diver state.
enum DiverState {
	SWIMMING,
	IN_SUBMARINE,
	DRIVING_SUBMARINE,
	OPERATING_MODULE,
	IN_GRAVITY_AREA,
}

## The success type this msision requires (used in a chain)
enum MissionSuccessType {
	ACQUIRE_ITEM, 
	DISCOVER_AREA,
	BUILD, 
}

## Type of error used for debug colors.
enum ErrorType {
	WARNING,
	ERROR,
	CRITICAL_ERROR,
}

# -- Classes -- 

## A slot in the player's inventory.
class InventorySlot:
	var item: InventoryItem
	var count: int

# -- General --

## Calls a specific function on a group of nodes over multiple frames.
static func multiframe_function_batches_on_group(group: Array[Node], function_name: String, args: Array, batch_size: int, tree: SceneTree) -> void:
	if group.size() % batch_size != 0:
		Global.print_error("Trying to call function batches with a group size not divisible by batch size. The last few objects will not have their functions called. Printing stack trace (in console).")
		print_stack()
	
	for i in range(int(group.size() / float(batch_size))):
		for j in range(batch_size):
			group[i * batch_size + j].callv(function_name, args)
		
		# Essentially wait a frame.
		await tree.create_timer(0.001).timeout

## Returns a new object of the same type if the variable is null.
static func safeguard_null(variable: Object, variable_class_name: String) -> Object:
	if variable == null:
		# Attempt to instantiate the object by the class name
		var class_type = ClassDB.instantiate(variable_class_name)
		
		printerr("A variable of type: " + variable_class_name + " was null.")
		print_stack()
		
		if class_type:
			return class_type
	
	return variable

## https://www.youtube.com/watch?v=Bf7vDBBOBUA
static func find_all_children_of_type(on: Node, type: String) -> Array[Object]:
	var output: Array[Object] = []
	
	for child in on.get_children():
		if child.get_class() == type:
			output.append(child)
		
		output.append_array(find_all_children_of_type(child, type))
	
	return output

# -- Physics --

## Perform a raycast in the world. Uses global positions.
static func do_raycast(world_2d: World2D, from: Vector2, to: Vector2) -> Dictionary:
	var space_state := world_2d.direct_space_state
	var raycast := PhysicsRayQueryParameters2D.create(from, to)
	return space_state.intersect_ray(raycast)

## Executes a pointcast on the world, using global positions.
static func do_pointcast(world_2d: World2D, point: Vector2, mask: int = 0xFFFFFFFF) -> Array[Dictionary]:
	var space_state := world_2d.direct_space_state
	var pointcast = PhysicsPointQueryParameters2D.new()
	pointcast.position = point
	pointcast.collision_mask = mask
	return space_state.intersect_point(pointcast)

# -- Math --

## Framerate independant linear interpolation.
static func better_lerp(from: float, to: float, weight: float, delta: float):
	# Convert decay from 0-1 to 1-25.
	weight = (weight * 25.0)
	return from + (to - from) * exp(-weight * delta)

## Framerate independant linear interpolation (Vector2).
static func better_vec2_lerp(a: Vector2, b: Vector2, decay: float, delta: float):
	return Vector2(better_lerp(a.x, b.x, decay, delta), better_lerp(a.y, b.y, decay, delta))

## Framerate independant linear interpolation for angles.
static func better_angle_lerp(a: float, b: float, decay: float, delta: float):
	decay = (decay * 25.0)
	return b + (angle_difference(b, a)) * exp(-decay * delta)

## Turns an angle in degrees and a magnitude in pixels to a vector.
static func angle_to_vector_degrees(angle: float, magnitude: float) -> Vector2:
	var x: float = magnitude * cos(deg_to_rad(angle))
	var y: float = magnitude * sin(deg_to_rad(angle))
	return Vector2(x, y)

## Turns an angle in radians and a magnitude in pixels into a vector.
static func angle_to_vector_radians(angle: float, magnitude: float) -> Vector2:
	var x: float = magnitude * cos(angle)
	var y: float = magnitude * sin(angle)
	return Vector2(x, y)

## Randomish direction.
static func random_direction(rng: RandomNumberGenerator) -> Vector2:
	return Vector2(rng.randf_range(-1, 1), rng.randf_range(-1, 1)).normalized()

## Randomish direction plus a random magnitude.
static func random_vector(rng: RandomNumberGenerator, max_length: float, min_length: float = 0) -> Vector2:
	return random_direction(rng) * rng.randf_range(min_length, max_length)

## Returns angle within the normal range (degrees)
static func normalize_angle_degrees(a: float) -> float:
	return fmod(fmod(a, 360) + 360, 360)

## Returns angle within the normal range (radians)
static func normalize_angle_radians(a: float) -> float:
	return fmod(fmod(a, TAU) + TAU, TAU)

## Smooths out a line.
static func smooth_line(input: PackedVector2Array, resolution_multiplier: float) -> PackedVector2Array:
	var output: PackedVector2Array = []
	var tangents: PackedVector2Array = []
	
	# Generate tangents ... This is making it a catmull-rom spline.
	# https://en.wikipedia.org/wiki/Cubic_Hermite_spline, Catmull-Rom section.
	for i in range(1, len(input) - 1):
		tangents.append((input[i + 1] - input[i - 1]) / 2.0)
	tangents.append(Vector2.ZERO)
	
	for i in range(1, len(input) - 1):
		for big_t in range(0, resolution_multiplier):
			var t = big_t / resolution_multiplier
			
			# Massive polynomial, who knows what it means.
			var pos = ((2 * t ** 3) - (3 * t ** 2) + 1) * input[i] + \
					  ((t ** 3) - (2 * t ** 2) + t) * tangents[i - 1] + \
					  ((-2 * t ** 3) + (3 * t ** 2)) * input[i + 1 - (1 if i == len(input) - 1 else 0)] + \
					  ((t ** 3) - (t ** 2)) * tangents[i]
			
			output.append(pos)
	
	return output

## Run code from a string
static func eval(input: String):
	var script_holder = RefCounted.new()
	var script = GDScript.new()
	script.set_source_code("func eval():" + input)
	script.reload()
	script_holder.set_script(script)
	return script_holder.eval()

static func clamp_vector_length(v: Vector2, min_length: float, max_length: float) -> Vector2:
	var len = v.length()
	if len == 0:
		return v
	var clamped_len = clamp(len, min_length, max_length)
	return v.normalized() * clamped_len

static func get_random_point_in_circle(circle_pos: Vector2, circle_radius: float) -> Vector2:
	while true:
		var rand_pos: Vector2 = Vector2(
			randi_range(circle_pos.x - circle_radius, circle_pos.x + circle_radius),
			randi_range(circle_pos.y - circle_radius, circle_pos.y + circle_radius)
		)
		
		if circle_pos.distance_to(rand_pos) <= circle_radius:
			return rand_pos
	
	return Vector2.ZERO # Shouldn't happen
