// Shared procedural noise, ported from Godot graphics/reference_look_pass/shaders/look_common.gdshaderinc.
// Do not edit the Godot originals; this is the Unity copy.

#ifndef GERTECH_LOOK_COMMON_INCLUDED
#define GERTECH_LOOK_COMMON_INCLUDED

float GertechHash13(float3 p)
{
    p = frac(p * 0.1031);
    p += dot(p, p.zyx + 31.32);
    return frac((p.x + p.y) * p.z);
}

float GertechNoise3(float3 x)
{
    float3 i = floor(x);
    float3 f = frac(x);
    f = f * f * (3.0 - 2.0 * f);
    return lerp(
        lerp(
            lerp(GertechHash13(i), GertechHash13(i + float3(1, 0, 0)), f.x),
            lerp(GertechHash13(i + float3(0, 1, 0)), GertechHash13(i + float3(1, 1, 0)), f.x),
            f.y),
        lerp(
            lerp(GertechHash13(i + float3(0, 0, 1)), GertechHash13(i + float3(1, 0, 1)), f.x),
            lerp(GertechHash13(i + float3(0, 1, 1)), GertechHash13(i + float3(1, 1, 1)), f.x),
            f.y),
        f.z);
}

float GertechFbm3(float3 p)
{
    float v = 0.0;
    float a = 0.5;
    [unroll]
    for (int i = 0; i < 4; i++)
    {
        v += a * GertechNoise3(p);
        p = p * 2.03 + float3(1.7, 9.2, 3.1);
        a *= 0.5;
    }
    return v;
}

float GertechStarPt(float3 p, float dens, float thresh)
{
    float3 g = p * dens;
    float3 cell = floor(g);
    float h = GertechHash13(cell);
    float3 local = frac(g) - 0.5;
    return step(thresh, h) * smoothstep(0.22, 0.0, length(local));
}

#endif
