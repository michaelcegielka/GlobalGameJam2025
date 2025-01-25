/*
	バブルシェーダー by あるる（きのもと 結衣） @arlez80
	Bubble Shader by Yui Kinomoto @arlez80
	Modified by Lars Gonikman

	MIT License
*/

shader_type spatial;

// Uniforms from the original shader
uniform float wobble_speed = 1.5;
uniform float wobble_size = 0.05;
uniform vec4 outline_color : source_color = vec4(0.45, 0.70, 1.0, 1.0);
uniform float outline_ratio = 1.0;
uniform float noise_speed = 0.2;
uniform float noise_scale = 0.5;

// Uniforms for thin-film interference
uniform float thickness_scale : hint_range(0, 100) = 32.0;
uniform float iridescence_intensity : hint_range(0, 1) = 0.5;
uniform float noise_scale_thin_film : hint_range(0, 10) = 1.0;
uniform float noise_speed_thin_film : hint_range(0, 2) = 0.5; // Speed of noise movement
uniform float noise_strength : hint_range(0, 10) = 5.0; // Strength of noise distortion

// Simple albedo color
uniform vec4 albedo_color : source_color = vec4(1.0);

// Helper functions
vec3 hsv2rgb(float h, float s, float v) {
    return (
        (
            clamp(
                abs(fract(h + vec3(0.0, 2.0, 1.0) / 3.0) * 6.0 - 3.0) - 1.0,
                0.0,
                1.0
            ) - 1.0
        ) * s + 1.0
    ) * v;
}

// 2D noise function for randomness
float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

// Moving noise for distortion
float movingNoise(vec3 pos, float time) {
    vec2 uv = pos.xy + pos.z; // Combine coordinates for 3D noise
    uv += time * noise_speed_thin_film; // Animate noise over time
    return 0.01; //rand(uv) * 2.0 - 1.0; // Noise in the range [-1, 1]
}

// Thin-film interference simulation with enhanced noise distortion
vec3 thinFilmInterference(vec3 normal, vec3 view_dir, vec3 vertex_pos, float time) {
    // Generate noise-driven thickness variation
    float noise = movingNoise(vertex_pos, time) * noise_scale_thin_film;
    float thickness = thickness_scale * (0.5 + 0.5 * noise);

    // Calculate interference color based on thickness and viewing angle
    float angle = dot(normal, view_dir);
    float interference = sin(thickness * angle * 10.0 + noise * noise_strength); // Add noise to distort bands

    // Map interference to a color spectrum
    vec3 iridescence = hsv2rgb(interference, 1.0, 1.0) * iridescence_intensity;
    return iridescence;
}

void vertex() {
    // Preserve the original vertex animation
    vec3 v = clamp(cos(VERTEX * 10.0 + vec3(TIME * wobble_speed)) + vec3(1.0), 0.0, 1.0);
    VERTEX *= 1.0 + dot(v, v) * wobble_size * 0.5;
}

void fragment() {
    // Calculate thin-film interference with enhanced noise distortion
    vec3 view_dir = normalize(VIEW);
    vec3 normal = NORMAL;
    vec3 vertex_pos = VERTEX; // Use vertex position for noise
    vec3 iridescence = thinFilmInterference(normal, view_dir, vertex_pos, TIME);

    // Combine with the original outline effect
    float outline_alpha = clamp((1.0 - dot(NORMAL, VIEW)) * outline_ratio, 0.0, 1.0);
    vec3 color = hsv2rgb(outline_alpha - 1.5 + noise_speed * TIME, 1.0, 1.0) * noise_scale;

    // Use the simple albedo color and add iridescence
    ALBEDO = mix(color, outline_color.rgb, max(outline_alpha - 0.3, 0.0)) + iridescence * albedo_color.rgb;
    ALPHA = outline_color.a * outline_alpha;
}