Shader "Gertech/CrystalNebula"
{
    Properties
    {
        [IntRange] _Element ("Element (0 nebula .. 8)", Range(0, 8)) = 0
        _Radius ("Radius", Float) = 1
        _Density ("Density", Range(0, 4)) = 1
        _HelixChannel ("Helix Channel", Range(0, 2)) = 0
        _AlphaBase ("Alpha Base", Range(0, 1)) = 0.72
        _EdgeColor ("Edge Color", Color) = (0.55, 0.95, 1, 1)
        _EdgeGlow ("Edge Glow", Range(0, 4)) = 0.9
        _Energy ("Energy", Range(0, 4)) = 1
    }
    CGINCLUDE
    #pragma target 3.0
    #include "UnityCG.cginc"
    #include "GertechLookCommon.hlsl"
    int _Element;
    float _Radius, _Density, _HelixChannel, _AlphaBase, _EdgeGlow, _Energy;
    float4 _EdgeColor;
    struct appdata { float4 vertex : POSITION; float3 normal : NORMAL; };
    struct v2f {
        float4 pos : SV_POSITION;
        float3 objPos : TEXCOORD0;
        float3 camObj : TEXCOORD1;
        float3 worldN : TEXCOORD2;
        float3 worldV : TEXCOORD3;
    };
    v2f gertech_crystal_vert(appdata v)
    {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.objPos = v.vertex.xyz;
        float3 camWorld = _WorldSpaceCameraPos;
        o.camObj = mul(unity_WorldToObject, float4(camWorld, 1)).xyz;
        float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
        o.worldN = UnityObjectToWorldNormal(v.normal);
        o.worldV = camWorld - worldPos;
        return o;
    }
    float4 sample_el(float3 p)
    {
        float t = _Time.y;
        float r = length(p);
        if (_Element == 1)
        {
            float n = GertechNoise3(p * 3.2 + float3(0, -t * 0.2, 0));
            float ridge = pow(1.0 - abs(2.0 * n - 1.0), 14.0);
            float base = GertechFbm3(p * 2.0);
            float3 c = lerp(float3(0.12, 0.01, 0.0), float3(1.0, 0.35, 0.05), ridge) + float3(1.0, 0.75, 0.3) * pow(ridge, 3.0);
            return float4(c * 1.6, 0.04 + ridge * 0.55 + base * 0.04);
        }
        else if (_Element == 2)
        {
            float n = GertechFbm3(p * 2.4 + t * 0.03);
            float3 c = lerp(float3(0.02, 0.18, 0.2), float3(0.65, 0.95, 0.95), smoothstep(0.35, 0.85, n));
            return float4(c, smoothstep(0.3, 0.8, n) * 0.22);
        }
        else if (_Element == 3)
        {
            float n = GertechFbm3(p * 2.2 + 5.0);
            float3 c = lerp(float3(0.1, 0.02, 0.25), float3(0.55, 0.25, 0.95), n);
            float b = GertechNoise3(p * float3(2.5, 6.0, 2.5) + floor(t * 3.0) * 1.7);
            float bolt = pow(1.0 - abs(2.0 * b - 1.0), 40.0);
            c += float3(0.85, 0.75, 1.0) * bolt * 4.0;
            return float4(c, smoothstep(0.35, 0.8, n) * 0.18 + bolt * 0.6);
        }
        else if (_Element == 4)
        {
            float a = atan2(p.z, p.x) + r * 5.0 - t * 0.35;
            float3 q = float3(cos(a) * r, p.y * 1.4, sin(a) * r);
            float n = GertechFbm3(q * 3.0);
            float3 c = lerp(float3(0.6, 0.25, 0.02), float3(1.0, 0.85, 0.45), n) * (0.7 + 1.6 * exp(-r * 4.0));
            return float4(c * 1.3, 0.12 + n * 0.25 + exp(-r * 5.0) * 0.5);
        }
        else if (_Element == 5)
        {
            float rr = length(p.xz) + 0.001;
            float a = atan2(p.z, p.x);
            float arms = pow(0.5 + 0.5 * cos(2.0 * a - log(rr) * 5.0 + t * 0.6), 3.0);
            float flatm = exp(-p.y * p.y * 10.0);
            float n = GertechFbm3(p * 3.0);
            float3 c = lerp(float3(0.45, 0.2, 0.75), float3(0.3, 0.9, 0.85), n) * arms + 1.0 * exp(-rr * 8.0);
            return float4(c * 1.3, (arms * 0.35 + exp(-rr * 6.0) * 0.6) * flatm);
        }
        else if (_Element == 6)
        {
            float n = GertechNoise3(p * 4.0);
            return float4(float3(0.6, 0.85, 0.95) * n, 0.025);
        }
        else if (_Element == 8)
        {
            float n = GertechNoise3(p * 3.5 + 1.0);
            float sp = GertechStarPt(p, 14.0, 0.86);
            float3 c = float3(0.85, 0.92, 1.0) * smoothstep(0.55, 0.9, n) * 0.7
                + lerp(float3(1.0, 0.8, 0.45), float3(0.6, 0.95, 1.0), GertechHash13(floor(p * 14.0) + 2.0)) * sp * 3.0;
            return float4(c, 0.05 + smoothstep(0.55, 0.9, n) * 0.12 + sp * 0.5);
        }
        else if (_Element == 7)
        {
            float n = GertechFbm3(p * 2.3 + t * 0.02);
            float m = GertechNoise3(p * 1.4 + 9.0);
            float3 c = lerp(float3(0.25, 0.08, 0.6), float3(1.0, 0.55, 0.18), smoothstep(0.45, 0.75, m)) * smoothstep(0.3, 0.8, n);
            c += float3(0.4, 0.5, 1.0) * smoothstep(0.6, 0.9, n);
            float star = GertechStarPt(p, 22.0, 0.93) * 2.5;
            return float4(c * 1.1 + star, smoothstep(0.3, 0.8, n) * 0.3 + star * 0.4);
        }
        {
            float n = GertechFbm3(p * 2.5 + t * 0.03);
            float3 c = lerp(float3(0.30, 0.06, 0.55), float3(0.10, 0.30, 0.85), GertechNoise3(p * 1.6 + 2.0)) * smoothstep(0.35, 0.8, n);
            c += float3(0.95, 0.4, 0.85) * smoothstep(0.72, 0.95, n) * 0.5;
            float star = GertechStarPt(p, 22.0, 0.93) * 2.5;
            return float4(c * 0.95 + star, smoothstep(0.35, 0.8, n) * 0.22 + star * 0.4);
        }
    }
    fixed4 gertech_crystal_frag(v2f i) : SV_Target
    {
        float rad = max(_Radius, 0.0001);
        float3 ro = i.objPos / rad;
        float3 rd = normalize(i.objPos - i.camObj);
        float3 acc = 0;
        float a = 0;
        [unroll]
        for (int s = 0; s < 10; s++)
        {
            float3 p = ro + rd * (0.03 + float(s) * 0.18);
            if (length(p) > 1.15 || a > 0.97) break;
            float4 samp = sample_el(p);
            samp.a = saturate(samp.a * _Density);
            if (_HelixChannel > 0.0)
            {
                float ph = p.y * 5.5 + _Time.y * 1.2;
                float2 c1 = float2(cos(ph), sin(ph)) * 0.2;
                float d = min(length(p.xz - c1), length(p.xz + c1));
                float g = exp(-d * d * 260.0) * _HelixChannel * step(abs(p.y), 0.85);
                samp.rgb += float3(0.3, 0.85, 1.0) * g * 3.0;
                samp.a = max(samp.a, g * 0.6);
            }
            acc += (1.0 - a) * samp.rgb * samp.a;
            a += (1.0 - a) * samp.a;
        }
        float fres = pow(1.0 - saturate(dot(normalize(i.worldN), normalize(i.worldV))), 2.5);
        float3 emission = acc * 1.25 * _Energy + _EdgeColor.rgb * fres * _EdgeGlow;
        float alpha = saturate(_AlphaBase * a + fres * 0.55 + 0.1);
        return fixed4(emission, alpha);
    }
    ENDCG

    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent" }
        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }
            Cull Back
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex gertech_crystal_vert
            #pragma fragment gertech_crystal_frag
            ENDCG
        }
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
        Pass
        {
            Name "ForwardBase"
            Tags { "LightMode" = "ForwardBase" }
            Cull Back
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex gertech_crystal_vert
            #pragma fragment gertech_crystal_frag
            ENDCG
        }
    }
    FallBack "Transparent/Diffuse"
}
