shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_nearest;
uniform vec2 screen_size = vec2(1152.0, 648.0);

uniform vec4[256] color_palette;
uniform int colors_amount = 10;
uniform int pixel_size = 4;

varying int closest_palette_index;


float get_color_difference(vec4 c1, vec4 c2) {
	vec3 diff = c1.rgb - c2.rgb;
	return dot(diff, diff);
}


void fragment() {
	// Pixelize
	vec2 factor = screen_size / float(pixel_size);
	vec2 grid_uv = round(SCREEN_UV * factor) / factor;

	vec4 pixelized_color = texture(screen_texture, grid_uv);

	// Match to palette
	float min_dif = 100000.0;
	closest_palette_index = 0;
	for (int i = 0; i < colors_amount; i++) {
		float current_dif = get_color_difference(pixelized_color, color_palette[i]);
		if (current_dif < min_dif) {
			min_dif = current_dif;
			closest_palette_index = i;
		}
	}

	vec4 quantized_color = color_palette[closest_palette_index];

	COLOR = quantized_color;
}