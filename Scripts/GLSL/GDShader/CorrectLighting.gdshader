shader_type canvas_item;

uniform sampler2D gun_texture; // The gun's texture
uniform sampler2D gradient_tex;              // The gradient texture for the heat effect

// How strongly the gradient tints the gun (0 = no tint, 1 = full tint)
uniform float blend_strength : hint_range(0.0, 1.0) = 1.0;

// Determines if the gradient should scroll vertically or horizontally
uniform bool vertical_gradient = false;

// Controls how fast the gradient scrolls over time.
uniform float speed = 1.0;

void fragment() {
    // Sample the gun texture normally using UV coordinates.
    vec4 base_color = texture(gun_texture, UV);

    // If the pixel is effectively transparent, keep it that way.
    if (base_color.a < 0.01) {
        discard;
    }

    // Compute the animated coordinate. Using TIME will create an animation effect.
    float gradient_coord = (vertical_gradient ? UV.y : UV.x) + (TIME * speed);

    // Wrap the coordinate so it loops when it goes past 1.0.
    gradient_coord = fract(gradient_coord);

    // Sample the gradient texture.
    // (If your gradient texture is 1D-like, sample along the x-axis, with y fixed to 0.0)
    vec4 grad_color = texture(gradient_tex, vec2(gradient_coord, 0.0));

    // Blend the gun's base color with the gradient effect.
    // Here, multiplying the base color by the gradient color gives a tinted effect.
    vec4 tinted_color = vec4(
        mix(base_color.rgb, base_color.rgb * grad_color.rgb, blend_strength),
        base_color.a
    );

    COLOR = tinted_color;
}
