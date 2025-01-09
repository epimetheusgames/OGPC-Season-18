shader_type canvas_item;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;

uniform float posterization_level;

void fragment() {
	vec4 base = texture(SCREEN_TEXTURE, SCREEN_UV);

	float gray = max(base.r, max(base.g, base.b));
	float lower = floor(gray * posterization_level) / posterization_level;
	float upper = ceil(gray * posterization_level) / posterization_level;

	float lower_diff = gray - lower;
	float upper_diff = upper - gray;

	float level = (lower_diff <= upper_diff) ? lower : upper;
	float adjustment = level / gray;

	COLOR = vec4(base.rgb * adjustment, 1);
}