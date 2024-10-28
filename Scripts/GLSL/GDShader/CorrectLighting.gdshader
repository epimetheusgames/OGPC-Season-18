shader_type canvas_item;

uniform vec4 water_col;

void light() {
	vec4 light = LIGHT_COLOR * LIGHT_ENERGY;
	LIGHT = water_col * light;
}
