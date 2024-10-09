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

# -- Math --

# Turns an angle and a magnitude to a vector.
static func angle_to_vector(angle: float, magnitude: float) -> Vector2:
	var x: float = magnitude * cos(angle)
	var y: float = magnitude * sin(angle)
	return Vector2(x, y)
