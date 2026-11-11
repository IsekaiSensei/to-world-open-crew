shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled;

// Underwater moving caustic glints. Purely visual; no resource/gameplay effect.
varying vec3 world_pos;

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    vec2 uv = world_pos.xz * 0.35;
    float a = sin(uv.x * 1.9 + TIME * 0.31 + sin(uv.y * 2.3 - TIME * 0.23));
    float b = sin(uv.y * 1.7 - TIME * 0.27 + sin(uv.x * 2.2 + TIME * 0.19));
    float c = sin((uv.x + uv.y) * 1.3 + TIME * 0.11);
    float wave = (a + b + c) / 3.0;
    float glint = smoothstep(0.57, 0.87, wave);
    ALBEDO = vec3(0.15, 0.72, 0.88);
    ALPHA = glint * 0.14;
}
