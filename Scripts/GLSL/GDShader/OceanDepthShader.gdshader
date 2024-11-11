shader_type canvas_item;

uniform vec4 water_col;
uniform vec4 shallow_water_col;
uniform sampler2D depth_color_tex : filter_linear;
uniform bool always_top = false;

void light() {
	vec4 light = LIGHT_COLOR * LIGHT_ENERGY;
	
	// Light is the sun
	float depth = !always_top ? UV.y : 0.0;
	if (LIGHT_IS_DIRECTIONAL) {
		vec4 color = texture(depth_color_tex, vec2(UV.x, depth));
		color.rgb = pow(color.rgb, vec3(2.2));
		light *= color * mix(1.0, 0.0, clamp(depth * 2.0, 0.0, 1.0));
	}
	
	LIGHT = mix(water_col, shallow_water_col, UV.x / 2.0 + 0.4) * light;
}
