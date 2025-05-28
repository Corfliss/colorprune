shader_type canvas_item;

uniform float time;
uniform float band_width = 0.0;
uniform float block_repeat = 20.0;

void fragment() {
	vec2 uv = clamp(UV, 0.0, 1.0);

	float scroll_speed = 0.2;
	float scroll = time * scroll_speed;

	// Move the diagonal line smoothly
	float diag = uv.x + (1.0 - uv.y) - scroll;

	// RGB diagonal stripes
	float index = mod(floor(diag * block_repeat), 3.0);

	vec4 background_color = vec4(0.17, 0.17, 0.17, 1.0); // Dark gray #2b2b2b
	vec4 rgb_color = background_color; // Default background
	if (index == 0.0) {
		rgb_color = vec4(0.9333, 0.2667, 0.2667, 1.0);
	} else if (index == 1.0) {
		rgb_color = vec4(0.2667, 0.2667, 0.9333, 1.0);
	} else {
		rgb_color = vec4(0.2667, 0.9333, 0.2667, 1.0);
	}

	// Optional: blend to fade edges of the band
	float band = smoothstep(0.0, band_width, fract(diag * block_repeat));

	COLOR = rgb_color * band;
}
