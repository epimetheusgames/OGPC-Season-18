shader_type canvas_item;

uniform vec4 color;
uniform float angle : hint_range(0,360);
uniform float len : hint_range(0,1000) = 300;
uniform float fade_margin : hint_range(0,100) = 5;

void fragment() {
	vec2 pos = SCREEN_UV;
	
	float ang_rad = angle * 3.1416 / 360.0 * 2.0;
	vec2 dir = vec2(sin(ang_rad),cos(ang_rad));
	float max_dist = len;
	vec2 at = screen_uv_to_sdf(pos);
	float accum = 0.0;
	
	//COLOR.xyz = vec3(texture_sdf(at) / 1000.0);

	while(accum < max_dist) {
	    float d = texture_sdf(at);
	    accum+=d;
	    if (d < 0.01) {
	        break;
	    }
	    at += d * dir;
	}
	
	if (accum >= max_dist) {
		accum = max_dist;
	}
	
	float alpha = 1.0-min(1.0,accum/max_dist);
	if (accum < fade_margin) {
		alpha *= max(0.0,accum / fade_margin);
	}

	// Pass data through.
	COLOR = vec4(vec3(accum, alpha * color.a, 0.0), 1.0);
}