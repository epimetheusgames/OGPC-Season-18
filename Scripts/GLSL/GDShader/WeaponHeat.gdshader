shader_type canvas_item;

uniform sampler2D gradient_texture; // The gradient texture for the heat effect

// How strongly the gradient tints the gun (0 = no tint, 1 = full tint)
uniform float blend_strength : hint_range(0.0, 1.0) = 1.0;

// Determines if the gradient should scroll vertically or horizontally
uniform bool vertical_gradient = true;

uniform float heat = 0.0;

uniform float max_heat = 100.0;

// Maximum gradient shift from the minimum
uniform float pixel_shift_range = 100.0;

// Minimum gradient shift caused by heat
uniform float min_pixel_shift = -95.0;

void fragment() {
	// Base texture pixel
	vec4 base_texture_pixel = texture(TEXTURE, UV);
	
	vec2 gradient_coords = vec2(clamp(UV.x - (min_pixel_shift + (heat / max_heat)*pixel_shift_range)/float(textureSize(TEXTURE, 0).x), 0.0, 1.0), UV.y);
	
	// Gradient texture pixel
	vec4 gradient_texture_pixel = texture(gradient_texture, gradient_coords);
	
	vec4 tinted_color = vec4(mix(base_texture_pixel.rgb, base_texture_pixel.rgb * gradient_texture_pixel.rgb, blend_strength), base_texture_pixel.a);
	COLOR = tinted_color;
	
}
