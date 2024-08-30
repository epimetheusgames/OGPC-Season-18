extends Node
class_name HelperFunctions

# This function seems useless...
func vec2_x_offset(vector: Vector2, offset: int) -> Vector2:
	var newVector = vector
	newVector.x += offset
	return newVector
