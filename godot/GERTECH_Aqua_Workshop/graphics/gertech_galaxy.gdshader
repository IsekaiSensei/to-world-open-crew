shader_type spatial;
render_mode cull_back, unshaded;

// Deterministic local-space cosmic crystal. No PNG, external textures,
// WorldSeed ports, or game-side data edits. GL Compatibility safe syntax.
varying vec3 local_p;

float hash31(vec3 p) {
    return fract(sin(dot(p, vec3(127.1, 311.7, 74.7))) * 43758.5453);
}

float noise3(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(mix(hash31(i), hash31(i + vec3(1., 0., 0.)), f.x),
                   mix(hash31(i + vec3(0., 1., 0.)), hash31(i + vec3(1., 1., 0.)), f.x), f.y),
               mix(mix(hash31(i + vec3(0., 0., 1.)), hash31(i + vec3(1., 0., 1.)), f.x),
                   mix(hash31(i + vec3(0., 1., 1.)), hash31(i + vec3(1., 1., 1.)), f.x), f.y), f.z);
}

void vertex() {
    local_p = VERTEX;
}

void fragment() {
    vec3 p = local_p * 4.2;
    float clouds = noise3(p * 2.6) * 0.55 + noise3(p * 5.0 + vec3(7.2, 1.4, 2.8)) * 0.45;
    float swirl = sin(p.x * 3.6 + p.y * 2.1 - p.z * 4.8 + clouds * 7.0);
    float bloom = smoothstep(0.16, 0.94, clouds + 0.16 * swirl);
    vec3 dark_blue = vec3(0.025, 0.04, 0.17);
    vec3 violet = vec3(0.35, 0.09, 0.60);
    vec3 cyan = vec3(0.09, 0.58, 0.87);
    vec3 gas = mix(violet, cyan, clamp(0.5 + 0.46 * swirl, 0.0, 1.0));
    vec3 color = mix(dark_blue, gas, bloom * 0.90);
    vec3 star_cell = floor((local_p + vec3(3.0)) * 55.0);
    float star = step(0.9955, hash31(star_cell));
    color += vec3(0.85, 0.96, 1.0) * star;
    ALBEDO = color;
    EMISSION = gas * bloom * 0.32 + vec3(star * 0.9);
}
