// Pixelizes the screen by rounding the uv to the nearest spot on the grid

shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_nearest;
uniform vec2 screen_size = vec2(1152.0, 648.0);

uniform int pixel_size = 4;

void fragment() {
	vec2 factor = screen_size / float(pixel_size);
	vec2 grid_uv = round(SCREEN_UV * factor) / factor;

	vec4 pixelized_color = texture(screen_texture, grid_uv);

	COLOR = pixelized_color;
}