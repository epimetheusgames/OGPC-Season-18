## Utility class, only static methods should be here.

class_name Util

# -- General --

# Returns a new object of the same type if the variable is null.
static func safeguard_null(variable: Object, variable_class_name: String) -> Object:
	if variable == null:
		# Attempt to instantiate the object by the class name
		var class_type = ClassDB.instantiate(variable_class_name)
		
		printerr("A variable of type: " + variable_class_name + " was null.")
		print_stack()
		
		if class_type:
			return class_type
	
	return variable

# -- Physics --

# Perform a raycast in the world. Uses GLOBAL positions.
static func do_raycast(world_2d: World2D, from: Vector2, to: Vector2) -> Dictionary:
	var space_state := world_2d.direct_space_state
	var raycast := PhysicsRayQueryParameters2D.create(from, to)
	return space_state.intersect_ray(raycast)

static func do_pointcast(world_2d: World2D, point: Vector2) -> Array[Dictionary]:
	var space_state := world_2d.direct_space_state
	var pointcast = PhysicsPointQueryParameters2D.new()
	pointcast.position = point
	return space_state.intersect_point(pointcast)

# -- Math --

# Framerate independant linear interpolation. A and B can be vectors of floats
# and the function will still work.
static func better_lerp(a: float, b: float, decay: float, delta: float):
	# Convert decay from 0-1 to 1-25.
	decay = (decay * 25.0)
	return b + (a - b) * exp(-decay * delta)

static func better_vec2_lerp(a: Vector2, b: Vector2, decay: float, delta: float):
	return Vector2(better_lerp(a.x, b.x, decay, delta), better_lerp(a.y, b.y, decay, delta))

# Framerate independant linear interpolation for angles.
static func better_angle_lerp(a: float, b: float, decay: float, delta: float):
	decay = (decay * 25.0)
	return b + (angle_difference(b, a)) * exp(-decay * delta)

# Turns an angle and a magnitude to a vector.
static func angle_to_vector(angle: float, magnitude: float) -> Vector2:
	var x: float = magnitude * cos(angle)
	var y: float = magnitude * sin(angle)
	return Vector2(x, y)
