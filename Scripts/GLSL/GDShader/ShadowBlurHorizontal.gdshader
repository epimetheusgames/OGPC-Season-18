shader_type canvas_item;

uniform vec4 color;
uniform float angle : hint_range(0,360);
uniform float len : hint_range(0,1000) = 300;
uniform float fade_margin : hint_range(0,100) = 5;
uniform float blur = 0.001;
uniform sampler2D screen_texture;

void fragment() {
	float accum = COLOR.r;
	float max_dist = len;
	
	accum = accum/max_dist * blur;
	
	//if (unweighted_accum > max_dist) {
		//unweighted_accum = texture(screen_texture, SCREEN_UV + vec2(accum * 4.0 * -SCREEN_PIXEL_SIZE.y, 0.0)).r;
		//accum = unweighted_accum/max_dist * blur;
	//}
	//if (unweighted_accum > max_dist) {
		//unweighted_accum = texture(screen_texture, SCREEN_UV + vec2(accum * 4.0 * SCREEN_PIXEL_SIZE.y, 0.0)).r;
		//accum = unweighted_accum/max_dist * blur;
	//}
	
	 //vec4 ours = texture(screen_texture, SCREEN_UV);
	//vec4 col = ours;
	//col.g *= 0.16;
	//for (int i = 0; i < 4; i++) {
		//vec4 left = texture(screen_texture, SCREEN_UV + vec2(float(i + 1) * offset_multiplier * SCREEN_PIXEL_SIZE.x, 0.0));
		//vec4 right = texture(screen_texture, SCREEN_UV + vec2(float(i + 1) * offset_multiplier * -SCREEN_PIXEL_SIZE.x, 0.0));
		//
		//left.g *= multiplier_array[i];
		//right.g *= multiplier_array[i];
		//
		//if (left.r / max_dist * blur < float(i + 1) / 4.0 * offset_multiplier) {
			//left = max(left, ours * multiplier_array[i]);
		//}
		//if (right.r / max_dist * blur < float(i + 1) / 4.0 * offset_multiplier) {
			//right = max(right, ours * multiplier_array[i]);
		//}
		//
		//col += left;
		//col += right;
	//}
	
	int offset_found = 0;
	bool found = false;
	if (texture(screen_texture, SCREEN_UV).r >= 480.0) {
		for (int i = 1; i <= int(blur) * 4; i++) {
			vec4 data = texture(screen_texture, SCREEN_UV + vec2(float(i) * SCREEN_PIXEL_SIZE.x, 0.0));
			if (data.r < 480.0) {
				accum = data.r/max_dist * blur;
				found = true;
				offset_found = i;
				break;
			}
		}
		if (!found) {
			for (int i = -1; i >= -int(blur) * 4; i--) {
				vec4 data = texture(screen_texture, SCREEN_UV + vec2(float(i) * SCREEN_PIXEL_SIZE.x, 0.0));
				if (data.r < 480.0) {
					accum = data.r/max_dist * blur;
					offset_found = i;
					found = true;
					break;
				}
			}
		}
	}
	
    vec4 col = texture(screen_texture, SCREEN_UV) * 0.16;
    col += texture(screen_texture, SCREEN_UV + vec2(accum * SCREEN_PIXEL_SIZE.x, 0.0)) * 0.15;
    col += texture(screen_texture, SCREEN_UV + vec2(accum * -SCREEN_PIXEL_SIZE.x, 0.0)) * 0.15;
    col += texture(screen_texture, SCREEN_UV + vec2(accum * 2.0 * SCREEN_PIXEL_SIZE.x, 0.0)) * 0.12;
    col += texture(screen_texture, SCREEN_UV + vec2(accum * 2.0 * -SCREEN_PIXEL_SIZE.x, 0.0)) * 0.12;
    col += texture(screen_texture, SCREEN_UV + vec2(accum * 3.0 * SCREEN_PIXEL_SIZE.x, 0.0)) * 0.09;
    col += texture(screen_texture, SCREEN_UV + vec2(accum * 3.0 * -SCREEN_PIXEL_SIZE.x, 0.0)) * 0.09;
    col += texture(screen_texture, SCREEN_UV + vec2(accum * 4.0 * SCREEN_PIXEL_SIZE.x, 0.0)) * 0.05;
    col += texture(screen_texture, SCREEN_UV + vec2(accum * 4.0 * -SCREEN_PIXEL_SIZE.x, 0.0)) * 0.05;
    COLOR = vec4(vec3(0.0, 0.0, 0.0), col.g);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
