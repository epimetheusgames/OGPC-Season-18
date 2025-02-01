shader_type canvas_item;

uniform sampler2D static_shadow_tex;
uniform sampler2D moving_shadow_tex;

void fragment() {
	vec4 static_col = texture(static_shadow_tex, SCREEN_UV);
	vec4 moving_col = texture(moving_shadow_tex, SCREEN_UV);
	vec4 final_col = max(static_col, moving_col);

	COLOR = mix(COLOR, vec4(0.0, 0.0, 0.0, 1.0), final_col.a);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
