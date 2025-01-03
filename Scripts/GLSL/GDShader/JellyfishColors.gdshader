shader_type canvas_item;

uniform vec4 colors[6];
uniform vec4 out_colors[6] : source_color;

void fragment() {
	for (int i = 0; i < 6; i++) {
		if (round(COLOR * 100.0) == round(colors[i] * 100.0)) {
			COLOR = out_colors[i];
		}
	}
	
}