shader_type canvas_item;

uniform vec4 water_col;
uniform sampler2D depth_color_tex : filter_linear;

void light() {
	vec4 light = LIGHT_COLOR * LIGHT_ENERGY;
	
	// Light is the sun
	float depth = UV.y;
	if (LIGHT_IS_DIRECTIONAL) {
		vec4 color = texture(depth_color_tex, vec2(0.0, depth));
		color.rgb = pow(color.rgb, vec3(2.2));
		light *= color * mix(1.0, 0.0, clamp(depth * 2.0, 0.0, 1.0));
	}
	
	LIGHT = water_col * light;
}
