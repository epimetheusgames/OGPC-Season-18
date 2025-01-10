// Pixelizes the screen by rounding the uv to the nearest spot on the grid

shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, repeat_disable, filter_nearest;
uniform vec2 SCREEN_SIZE = vec2(1920.0, 1080.0);

uniform float pixelization_level: hint_range(0.0, 10.0);

void fragment() {
	vec2 factor = SCREEN_SIZE / pixelization_level;
	vec2 grid_uv = round(SCREEN_UV * factor) / factor;

	vec4 pixelized_color = texture(SCREEN_TEXTURE, grid_uv);

	COLOR = pixelized_color;
}