shader_type sky;

uniform float time;
uniform float band_width: hint_range(0.01, 2) = 0.1;
uniform float block_repeat: hint_range(1.0, 50.0) = 20.0;
uniform float scroll_speed: hint_range(0.0, 1.0) = 0.2;

// Rotation speed in radians per second
uniform float spin_angle = 0.0;  // spin angle in radians.0) = 1.0;

// Colors
uniform vec3 color_1: source_color = vec3(0.9333, 0.2667, 0.2667);
uniform vec3 color_2: source_color = vec3(0.2667, 0.2667, 0.9333);
uniform vec3 color_3: source_color = vec3(0.2667, 0.9333, 0.2667);
uniform vec3 background_color: source_color = vec3(0.17, 0.17, 0.17);

void sky() {
    // Get sky coordinates (range 0..1)
    float phi = TAU * SKY_COORDS.x;
    float theta = PI * SKY_COORDS.y;

    // Convert spherical coords to 3D direction vector
    float st = sin(theta);
    vec3 sky_dir = vec3(st * sin(phi), cos(theta), -st * cos(phi));

    // Rotate around Y axis by spin_angle
    float cos_a = cos(spin_angle);
    float sin_a = sin(spin_angle);
    vec3 rotated_dir = vec3(
        cos_a * sky_dir.x + sin_a * sky_dir.z,
        sky_dir.y,
        -sin_a * sky_dir.x + cos_a * sky_dir.z
    );

    // Convert rotated_dir back to spherical UV
    float u = atan(rotated_dir.x, -rotated_dir.z) / TAU + 0.5;
    float v = acos(rotated_dir.y) / PI;

    // Use these UVs for diagonal pattern
    float scroll = time * scroll_speed;
    float diag = u + (1.0 - v) - scroll;

    float index = mod(floor(diag * block_repeat), 3.0);

    vec3 rgb_color = background_color;
    if (index == 0.0) {
        rgb_color = color_1;
    } else if (index == 1.0) {
        rgb_color = color_2;
    } else {
        rgb_color = color_3;
    }

    float band = smoothstep(0.0, band_width, fract(diag * block_repeat));

    COLOR = mix(background_color, rgb_color, band);
}