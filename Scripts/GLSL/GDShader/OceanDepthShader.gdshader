shader_type canvas_item;

uniform vec4 water_col;
uniform vec4 shallow_water_col;
uniform sampler2D depth_color_tex : filter_linear;
uniform bool always_top = false;
uniform bool blend_alpha = false;
uniform float max_alpha = 0.2;
uniform float height = 1.0;

void fragment() {
	if (blend_alpha) {
		float depth = !always_top ? UV.y : 0.0;
		COLOR.a = mix(0.8, max_alpha, clamp(depth * height, 0.0, 1.0));
	}
	
	//float depth = !always_top ? UV.y : 0.0;
	//vec4 color = texture(depth_color_tex, vec2(always_top ? (1.0 - UV.x) : UV.x, depth));
	//color.rgb = pow(color.rgb, vec3(2.2));
	//color *= mix(1.0, 0.0, clamp(depth * 2.0, 0.0, 1.0));
	//
	//COLOR = mix(water_col, shallow_water_col, (always_top ? (1.0-UV.x) : UV.x) / 2.0 + 0.4);
}

void light() {
	if (LIGHT_IS_DIRECTIONAL) {
		float depth = !always_top ? UV.y : 0.0;
		vec4 color = texture(depth_color_tex, vec2(always_top ? (1.0-UV.x) : UV.x, depth));
		color.rgb = pow(color.rgb, vec3(2.2));
		color *= mix(1.0, 0.0, clamp(depth * 2.0, 0.0, 1.0));
		LIGHT = mix(water_col, shallow_water_col, (always_top ? (1.0-UV.x) : UV.x) / 2.0 + 0.4) * color;
	}
	else {
		LIGHT = vec4(LIGHT_COLOR.rgb * COLOR.rgb * LIGHT_ENERGY, LIGHT_COLOR.a);
	}
}
