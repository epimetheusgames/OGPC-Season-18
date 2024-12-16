shader_type canvas_item;

uniform sampler2D noise: repeat_enable;

uniform float intensity : hint_range(0.0,1.0) = 0.05;
uniform sampler2D screen_tex: hint_screen_texture, filter_nearest;

void fragment() {

	vec2 direction = vec2(-0.2, 0.2);

	float movement = TIME * 3.0;
	vec4 displacement = texture(noise, fract(UV - direction * movement));
	float displacement_length = length(displacement.rg);
	vec2 uv = SCREEN_UV + displacement.rg * intensity * displacement_length;

	COLOR = vec4(texture(screen_tex, uv).rgb, 1.0);

}