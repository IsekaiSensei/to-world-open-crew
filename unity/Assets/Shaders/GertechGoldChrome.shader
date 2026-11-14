Shader "Gertech/GoldChrome"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 0.74, 0.32, 1)
        _Roughness ("Roughness", Range(0, 1)) = 0.2
        _RimColor ("Rim Color", Color) = (0.25, 0.92, 1, 1)
        _RimStrength ("Rim Strength", Range(0, 4)) = 0.7
        _RimPower ("Rim Power", Range(0.5, 8)) = 3
        _EnvStrength ("Env Strength", Range(0, 3)) = 0.85
        _Engrave ("Engrave", Range(0, 2)) = 0
    }
    // URP first (no package include — uses UnityCG, which is present in both pipelines).
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" "Queue" = "Geometry" }
        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }
            Cull Back
            ZWrite On
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #include "UnityCG.cginc"
            #include "GertechLookCommon.hlsl"
            float4 _BaseColor;
            float _Roughness;
            float4 _RimColor;
            float _RimStrength;
            float _RimPower;
            float _EnvStrength;
            float _Engrave;
            struct appdata { float4 vertex : POSITION; float3 normal : NORMAL; };
            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 worldN : TEXCOORD1;
                float3 worldV : TEXCOORD2;
            };
            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldN = UnityObjectToWorldNormal(v.normal);
                o.worldV = _WorldSpaceCameraPos - o.worldPos;
                return o;
            }
            fixed4 frag(v2f i) : SV_Target
            {
                float3 n = normalize(i.worldN);
                float3 vdir = normalize(i.worldV);
                float3 r = reflect(-vdir, n);
                float band = exp(-pow((r.y - 0.06) * 6.0, 2.0));
                float top = smoothstep(0.25, 1.0, r.y) * 0.55;
                float streak = pow(max(0.0, sin(atan2(r.z, r.x) * 5.0)), 18.0);
                float env = band * 1.05 + top + streak * band * 0.8 + 0.06;
                float lines = 0.0;
                if (_Engrave > 0.0)
                {
                    float f = GertechFbm3(i.worldPos * 7.0);
                    lines = (smoothstep(0.47, 0.5, f) - smoothstep(0.5, 0.53, f)) * _Engrave;
                }
                float fres = pow(1.0 - saturate(dot(n, vdir)), _RimPower);
                float3 base = _BaseColor.rgb;
                // Procedural studio reflection as emission, because a black sky reflects nothing.
                float3 emission = base * env * _EnvStrength * (1.0 - lines * 0.75) + _RimColor.rgb * fres * _RimStrength;
                float3 albedo = base * (0.35 + 0.65 * (1.0 - _Roughness));
                return fixed4(albedo + emission, 1);
            }
            ENDCG
        }
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }
        Pass
        {
            Name "ForwardBase"
            Tags { "LightMode" = "ForwardBase" }
            Cull Back
            ZWrite On
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #include "UnityCG.cginc"
            #include "GertechLookCommon.hlsl"
            float4 _BaseColor;
            float _Roughness;
            float4 _RimColor;
            float _RimStrength;
            float _RimPower;
            float _EnvStrength;
            float _Engrave;
            struct appdata { float4 vertex : POSITION; float3 normal : NORMAL; };
            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 worldN : TEXCOORD1;
                float3 worldV : TEXCOORD2;
            };
            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldN = UnityObjectToWorldNormal(v.normal);
                o.worldV = _WorldSpaceCameraPos - o.worldPos;
                return o;
            }
            fixed4 frag(v2f i) : SV_Target
            {
                float3 n = normalize(i.worldN);
                float3 vdir = normalize(i.worldV);
                float3 r = reflect(-vdir, n);
                float band = exp(-pow((r.y - 0.06) * 6.0, 2.0));
                float top = smoothstep(0.25, 1.0, r.y) * 0.55;
                float streak = pow(max(0.0, sin(atan2(r.z, r.x) * 5.0)), 18.0);
                float env = band * 1.05 + top + streak * band * 0.8 + 0.06;
                float lines = 0.0;
                if (_Engrave > 0.0)
                {
                    float f = GertechFbm3(i.worldPos * 7.0);
                    lines = (smoothstep(0.47, 0.5, f) - smoothstep(0.5, 0.53, f)) * _Engrave;
                }
                float fres = pow(1.0 - saturate(dot(n, vdir)), _RimPower);
                float3 base = _BaseColor.rgb;
                float3 emission = base * env * _EnvStrength * (1.0 - lines * 0.75) + _RimColor.rgb * fres * _RimStrength;
                float3 albedo = base * (0.35 + 0.65 * (1.0 - _Roughness));
                return fixed4(albedo + emission, 1);
            }
            ENDCG
        }
    }
    FallBack "Standard"
}
