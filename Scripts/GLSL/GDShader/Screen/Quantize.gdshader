// Quantization or posterization limits the amounts of colors on the screen
// This is done by matching each color it's the closest match in the palette

shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_nearest;

uniform vec4[256] color_palette;
uniform int colors_amount = 10;

varying int closest_palette_index;

// Function to convert RGB to XYZ
vec3 rgb_to_xyz(vec3 color) {
    // Gamma correction to linear space
    color = step(vec3(0.04045), color) * pow((color + vec3(0.055)) / 1.055, vec3(2.4)) +
            (1.0 - step(vec3(0.04045), color)) * (color / 12.92);
    
    color *= 100.0; // Scale to [0, 100] for XYZ conversion

    // Convert to XYZ using standard D65 illuminant
    return vec3(
        0.4124 * color.r + 0.3576 * color.g + 0.1805 * color.b,
        0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b,
        0.0193 * color.r + 0.1192 * color.g + 0.9505 * color.b
    );
}

// Function to convert XYZ to LAB
vec3 xyz_to_lab(vec3 xyz) {
    // Reference white for D65 illuminant
    vec3 ref_white = vec3(95.047, 100.000, 108.883);
    xyz /= ref_white;

    // LAB nonlinear transformation
    xyz = step(vec3(0.008856), xyz) * pow(xyz, vec3(1.0 / 3.0)) +
          (1.0 - step(vec3(0.008856), xyz)) * (xyz * 7.787 + vec3(16.0 / 116.0));

    return vec3(
        116.0 * xyz.y - 16.0,         // L
        500.0 * (xyz.x - xyz.y),      // a
        200.0 * (xyz.y - xyz.z)       // b
    );
}

// Function to convert RGB to LAB
vec3 rgb_to_lab(vec3 color) {
    vec3 xyz = rgb_to_xyz(color);
    return xyz_to_lab(xyz);
}



// Function to calculate color difference in LAB space
float get_color_difference(vec4 c1, vec4 c2) {
    vec3 lab1 = rgb_to_lab(c1.rgb);
    vec3 lab2 = rgb_to_lab(c2.rgb);
    
    vec3 diff = lab1 - lab2;
    return dot(diff, diff); // Squared Euclidean distance
}

void fragment() {
	vec4 screen_color = texture(screen_texture, SCREEN_UV);

	float min_dif = 100000.0;
	closest_palette_index = 0;
	for (int i = 0; i < colors_amount; i++) {
		float current_dif = get_color_difference(screen_color, color_palette[i]);
		if (current_dif < min_dif) {
			min_dif = current_dif;
			closest_palette_index = i;
		}
	}

	vec4 quantized_color = color_palette[closest_palette_index];

	COLOR = quantized_color;
}