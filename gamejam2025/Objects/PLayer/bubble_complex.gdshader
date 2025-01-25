/*
	Bubble Shader - Extreme Iridescence
	by Yui Kinomoto @arlez80
	Modified by Assistant
*/

shader_type spatial;

// Base Appearance
uniform vec4 base_color : source_color = vec4(0.8, 0.9, 1.0, 0.5);
uniform float metallic : hint_range(0, 1) = 0.9;
uniform float roughness : hint_range(0, 1) = 0.1;

// Iridescence Control
uniform float intensity : hint_range(0, 10) = 5.0;
uniform float frequency : hint_range(1, 100) = 30.0; // Adjusted frequency for fewer but visible bands
uniform float noise_scale : hint_range(0, 10) = 2.0;
uniform float distortion_strength : hint_range(0, 10) = 3.0;

// Noise Parameters
uniform float noise_amplitude : hint_range(0, 10) = 1.0;
uniform float noise_speed : hint_range(0, 2) = 0.5;
uniform float noise_detail : hint_range(1, 10) = 4.0;

// Animation
uniform float time_scale : hint_range(0, 2) = 0.5;

// Improved 3D Noise Function (Based on IQ's noise)
vec3 mod289_3(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec4 mod289_4(vec4 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }

vec4 permute(vec4 x) { return mod289_4(((x*34.0)+1.0)*x); }
vec4 taylorInvSqrt(vec4 r) { return 1.79284291400159 - 0.85373472095314 * r; }

float snoise(vec3 v) {
    const vec2 C = vec2(1.0/6.0, 1.0/3.0);
    const vec4 D = vec4(0.0, 0.5, 1.0, 2.0);

    vec3 i  = floor(v + dot(v, C.yyy));
    vec3 x0 = v - i + dot(i, C.xxx);

    vec3 g = step(x0.yzx, x0.xyz);
    vec3 l = 1.0 - g;
    vec3 i1 = min(g.xyz, l.zxy);
    vec3 i2 = max(g.xyz, l.zxy);

    vec3 x1 = x0 - i1 + C.xxx;
    vec3 x2 = x0 - i2 + C.yyy;
    vec3 x3 = x0 - D.yyy;

    i = mod289_3(i);
    vec4 p = permute(permute(permute(
             i.z + vec4(0.0, i1.z, i2.z, 1.0))
           + i.y + vec4(0.0, i1.y, i2.y, 1.0))
           + i.x + vec4(0.0, i1.x, i2.x, 1.0));

    float n_ = 0.142857142857;
    vec3  ns = n_ * D.wyz - D.xzx;

    vec4 j = p - 49.0 * floor(p * ns.z * ns.z);

    vec4 x_ = floor(j * ns.z);
    vec4 y_ = floor(j - 7.0 * x_);

    vec4 x = x_ *ns.x + ns.yyyy;
    vec4 y = y_ *ns.x + ns.yyyy;
    vec4 h = 1.0 - abs(x) - abs(y);

    vec4 b0 = vec4(x.xy, y.xy);
    vec4 b1 = vec4(x.zw, y.zw);

    vec4 s0 = floor(b0)*2.0 + 1.0;
    vec4 s1 = floor(b1)*2.0 + 1.0;
    vec4 sh = -step(h, vec4(0.0));

    vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy;
    vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww;

    vec3 p0 = vec3(a0.xy,h.x);
    vec3 p1 = vec3(a0.zw,h.y);
    vec3 p2 = vec3(a1.xy,h.z);
    vec3 p3 = vec3(a1.zw,h.w);

    vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
    p0 *= norm.x;
    p1 *= norm.y;
    p2 *= norm.z;
    p3 *= norm.w;

    vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
    m = m * m;
    return 42.0 * dot(m*m, vec4(dot(p0,x0), dot(p1,x1),
                                dot(p2,x2), dot(p3,x3)));
}

// Fractal Brownian Motion
float fbm(vec3 p, int octaves) {
    float total = 0.0;
    float amplitude = noise_amplitude;
    for(int i=0; i<octaves; i++) {
        total += snoise(p) * amplitude;
        p *= 2.0;
        amplitude *= 0.5;
    }
    return total;
}

void fragment() {
    // Base coordinates with distortion
    vec3 distorted_pos = VERTEX +
        vec3(
            fbm(VERTEX * noise_scale + TIME * noise_speed, int(noise_detail)) * distortion_strength,
            fbm(VERTEX * noise_scale + TIME * noise_speed + vec3(10.0), int(noise_detail)) * distortion_strength,
            fbm(VERTEX * noise_scale + TIME * noise_speed + vec3(20.0), int(noise_detail)) * distortion_strength
        );

    // Create swirling patterns (with visible but fewer bands)
    float pattern = sin(
        frequency * 0.5 * (dot(NORMAL, VIEW) + 0.5) + // Adjusted frequency for fewer bands
        fbm(distorted_pos * noise_scale + TIME * noise_speed, int(noise_detail)) * 7.0 // Noise influence
    );

    // Multi-wavelength interference
    vec3 color = vec3(
        sin(pattern * 3.0 + TIME) * 0.5 + 0.5,
        sin(pattern * 5.0 + TIME * 1.2) * 0.5 + 0.5,
        sin(pattern * 7.0 + TIME * 0.8) * 0.5 + 0.5
    );

    // Clamp and normalize the color to avoid black areas
    color = clamp(color, vec3(0.0), vec3(1.0));

    // Intensity and blending
    color = pow(color * intensity, vec3(2.2)); // Gamma for vibrancy
    color = mix(base_color.rgb, color, base_color.a);

    // Calculate transparency based on normal angle
    float normal_angle = dot(NORMAL, VIEW);
    float alpha = smoothstep(0.0, 1.0, abs(normal_angle)); // More transparent at center, less at edges
    alpha = mix(0.8, 0.2, alpha); // Adjust transparency range (0.8 at center, 0.2 at edges)

    // Final output
    ALBEDO = color;
    METALLIC = metallic;
    ROUGHNESS = roughness;
    ALPHA = alpha; // Use the calculated transparency
}