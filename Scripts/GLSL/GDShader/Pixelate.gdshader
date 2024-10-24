shader_type canvas_item;

uniform int width = 32;

void fragment()
{
	vec2 grid_uv = round(UV * float(width)) / float(width);
	
	COLOR = texture(TEXTURE, grid_uv);
}