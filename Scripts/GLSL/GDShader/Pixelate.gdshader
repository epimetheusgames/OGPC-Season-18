shader_type canvas_item;

uniform float pixel_size = 4;

uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_nearest;

void fragment()
{
	vec2 grid_uv = round(UV * vec2(1920.0, 1080.0) / float(pixel_size)) / vec2(1920.0, 1080.0) * float(pixel_size);

	COLOR = texture(screen_texture, grid_uv);
}