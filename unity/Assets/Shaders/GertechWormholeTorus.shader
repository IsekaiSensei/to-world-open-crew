Shader "Gertech/WormholeTorus"
{
    Properties
    {
        _Speed ("Speed", Range(0, 2)) = 0.35
        _Energy ("Energy", Range(0, 6)) = 1.25
        _DistortStrength ("Distort Strength", Range(0, 0.2)) = 0.06
    }
    CGINCLUDE
    #pragma target 3.0
    #include "UnityCG.cginc"
    #include "GertechLookCommon.hlsl"
    float _Speed, _Energy, _DistortStrength;
    sampler2D _CameraOpaqueTexture;
    sampler2D _GrabTexture;
    float4 _GrabTexture_TexelSize;
    struct appdata { float4 vertex : POSITION; float3 normal : NORMAL; float2 uv : TEXCOORD0; };
    struct v2f {
        float4 pos : SV_POSITION;
        float2 uv : TEXCOORD0;
        float3 worldN : TEXCOORD1;
        float3 worldV : TEXCOORD2;
        float4 screenPos : TEXCOORD3;
    };
    v2f gertech_wh_vert(appdata v)
    {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.uv = v.uv;
        float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
        o.worldN = UnityObjectToWorldNormal(v.normal);
        o.worldV = _WorldSpaceCameraPos - worldPos;
        o.screenPos = ComputeScreenPos(o.pos);
        return o;
    }
    float3 filaments(float2 uv)
    {
        float u = uv.x;
        float v = uv.y;
        float n = GertechNoise3(float3(u * 140.0 - _Time.y * _Speed * 20.0, v * 9.0 + u * 20.0, 0.0));
        float m = GertechNoise3(float3(u * 30.0 + _Time.y * _Speed * 6.0, v * 3.0, 4.0));
        float fil = pow(n, 6.0) * 2.2 + pow(m, 6.0) * 0.9;
        float3 gold = float3(1.0, 0.72, 0.32);
        float3 silver = float3(0.82, 0.88, 0.95);
        float3 cyan = float3(0.25, 0.85, 1.0);
        float3 c = lerp(lerp(gold, silver, smoothstep(0.3, 0.7, m)), cyan,
            smoothstep(0.55, 0.9, GertechNoise3(float3(u * 12.0, v * 2.0, 8.0))));
        return c * fil * _Energy;
    }
    ENDCG

    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent" }
        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }
            Cull Off
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex gertech_wh_vert
            #pragma fragment frag
            fixed4 frag(v2f i) : SV_Target
            {
                float3 n = normalize(i.worldN);
                float3 vdir = normalize(i.worldV);
                float f = pow(saturate(abs(dot(n, vdir))), 0.8);
                float2 suv = i.screenPos.xy / max(i.screenPos.w, 1e-5);
                // Refraction / swirl offset. Requires the URP asset's Opaque Texture enabled.
                float2 swirl = float2(n.x, n.y) * _DistortStrength + float2(
                    sin(_Time.y * _Speed * 2.0 + i.uv.y * 8.0),
                    cos(_Time.y * _Speed * 2.0 + i.uv.x * 8.0)) * _DistortStrength * 0.5;
                float3 bg = tex2D(_CameraOpaqueTexture, suv + swirl).rgb;
                float3 fil = filaments(i.uv) * (0.3 + 0.7 * f);
                float fres = pow(1.0 - saturate(abs(dot(n, vdir))), 1.5);
                float3 col = bg * (0.55 + 0.45 * f) + fil + float3(0.15, 0.55, 0.75) * fres * 0.35;
                float alpha = saturate(0.55 + length(fil) * 0.35 + fres * 0.25);
                return fixed4(col, alpha);
            }
            ENDCG
        }
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
        GrabPass { "_GrabTexture" }
        Pass
        {
            Name "ForwardBase"
            Tags { "LightMode" = "ForwardBase" }
            Cull Off
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex gertech_wh_vert
            #pragma fragment frag
            fixed4 frag(v2f i) : SV_Target
            {
                float3 n = normalize(i.worldN);
                float3 vdir = normalize(i.worldV);
                float f = pow(saturate(abs(dot(n, vdir))), 0.8);
                float2 suv = i.screenPos.xy / max(i.screenPos.w, 1e-5);
                float2 swirl = float2(n.x, n.y) * _DistortStrength + float2(
                    sin(_Time.y * _Speed * 2.0 + i.uv.y * 8.0),
                    cos(_Time.y * _Speed * 2.0 + i.uv.x * 8.0)) * _DistortStrength * 0.5;
                float3 bg = tex2D(_GrabTexture, suv + swirl).rgb;
                float3 fil = filaments(i.uv) * (0.3 + 0.7 * f);
                float fres = pow(1.0 - saturate(abs(dot(n, vdir))), 1.5);
                float3 col = bg * (0.55 + 0.45 * f) + fil + float3(0.15, 0.55, 0.75) * fres * 0.35;
                float alpha = saturate(0.55 + length(fil) * 0.35 + fres * 0.25);
                return fixed4(col, alpha);
            }
            ENDCG
        }
    }
    FallBack Off
}
