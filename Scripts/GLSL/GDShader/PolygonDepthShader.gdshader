shader_type canvas_item;
render_mode world_vertex_coords;

uniform vec2 points[100];
uniform int num_points;
uniform vec2 global_position;
uniform int fade_width;
uniform float tex_scale;

uniform sampler2D in_tex : repeat_enable;
uniform sampler2D edge_tex : repeat_enable;

varying vec2 world_pos;

void vertex() {
	world_pos = VERTEX;
}

void fragment() {
	vec2 position = world_pos;
	vec2 closest_point_pos = vec2(0.0, 0.0);
	float closest_point_dist = 999999999.0;

	for (int i = 0; i < num_points; i++) {
		int to_use = i - 1;
		if (i == 0) {
			to_use = num_points - 1;
		}

		vec2 p1 = global_position + points[i];
		vec2 p2 = global_position + points[to_use];

		if (abs(p1.x - position.x) + abs(p1.y - position.y) > 2000.0) {
			continue;
		}
		if (abs(p2.x - position.x) + abs(p2.y - position.y) > 2000.0) {
			continue;
		}

		vec2 p = position - p1;
		vec2 n = p2 - p1;
		float l2 = dot(n, n);

		float d = dot(n, p) / l2;
		vec2 closest_point;

		if (d <= 0.0) {
			closest_point = p1;
		}
		else if (d >= 1.0f) {
			closest_point = p2;
		}
		else {
			closest_point = p1 + n * d;
		}

		float dist = distance(position, closest_point);

		if (dist < closest_point_dist) {
			closest_point_pos = closest_point;
			closest_point_dist = dist;
		}
	}

	float fade_amm = clamp(closest_point_dist / float(fade_width), 0.0, 1.0);

	vec4 in_pixel = texture(in_tex, position / tex_scale);
	vec4 edge_pixel = texture(edge_tex, position / tex_scale);

	COLOR = mix(edge_pixel, in_pixel, fade_amm);
}