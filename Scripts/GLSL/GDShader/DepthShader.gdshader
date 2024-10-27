shader_type canvas_item;

uniform vec4 depth_col;

void fragment() {
	COLOR = mix(COLOR, depth_col, UV.y);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
