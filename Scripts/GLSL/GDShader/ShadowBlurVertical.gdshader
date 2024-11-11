shader_type canvas_item;

uniform vec4 color;
uniform float angle : hint_range(0,360);
uniform float len : hint_range(0,1000) = 300;
uniform float fade_margin : hint_range(0,100) = 5;
uniform float blur = 0.001;
uniform sampler2D screen_texture;

void fragment() {
	vec2 pos = SCREEN_UV;
	
	float ang_rad = angle * 3.1416 / 360.0 * 2.0;
	vec2 dir = vec2(sin(ang_rad),cos(ang_rad));
	float max_dist = len;
	vec2 at = screen_uv_to_sdf(pos);
	float accum = 0.0;

	while(accum < max_dist) {
	    float d = texture_sdf(at);
	    accum+=d;
	    if (d < 0.01) {
	        break;
	    }
	    at += d * dir;
	}
	float alpha = 1.0-min(1.0,accum/max_dist);
	if (accum < fade_margin) {
		alpha *= max(0.0,accum / fade_margin);
	}
	
	accum = min(1.0,accum/max_dist) * blur;
	
    vec4 col = texture(screen_texture, SCREEN_UV) * 0.16;
    col += texture(screen_texture, SCREEN_UV + vec2(0.0, accum * SCREEN_PIXEL_SIZE.y)) * 0.15;
    col += texture(screen_texture, SCREEN_UV + vec2(0.0, accum * -SCREEN_PIXEL_SIZE.y)) * 0.15;
    col += texture(screen_texture, SCREEN_UV + vec2(0.0, accum * 2.0 * SCREEN_PIXEL_SIZE.y)) * 0.12;
    col += texture(screen_texture, SCREEN_UV + vec2(0.0, accum * 2.0 * -SCREEN_PIXEL_SIZE.y)) * 0.12;
    col += texture(screen_texture, SCREEN_UV + vec2(0.0, accum * 3.0 * SCREEN_PIXEL_SIZE.y)) * 0.09;
    col += texture(screen_texture, SCREEN_UV + vec2(0.0, accum * 3.0 * -SCREEN_PIXEL_SIZE.y)) * 0.09;
    col += texture(screen_texture, SCREEN_UV + vec2(0.0, accum * 4.0 * SCREEN_PIXEL_SIZE.y)) * 0.05;
    col += texture(screen_texture, SCREEN_UV + vec2(0.0, accum * 4.0 * -SCREEN_PIXEL_SIZE.y)) * 0.05;
    COLOR = col;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
