Shader "Gertech/EdgeGlow"
{
    Properties
    {
        _Color ("Color", Color) = (0.3, 0.95, 1, 1)
        _Energy ("Energy", Range(0, 8)) = 1.6
        _FlowSpeed ("Flow Speed", Range(0, 4)) = 0.5
        _FlowDensity ("Flow Density", Range(0, 16)) = 3
        _Soft ("Soft", Range(0.1, 8)) = 1.5
        _Fade ("Fade", Range(0, 2)) = 1
    }
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent" }
        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }
            Cull Off
            ZWrite Off
            ZTest LEqual
            Blend One One
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #include "UnityCG.cginc"
            float4 _Color;
            float _Energy, _FlowSpeed, _FlowDensity, _Soft, _Fade;
            struct appdata { float4 vertex : POSITION; float3 normal : NORMAL; float2 uv : TEXCOORD0; };
            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldN : TEXCOORD1;
                float3 worldV : TEXCOORD2;
            };
            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldN = UnityObjectToWorldNormal(v.normal);
                o.worldV = _WorldSpaceCameraPos - worldPos;
                return o;
            }
            fixed4 frag(v2f i) : SV_Target
            {
                float pulse = 0.7 + 0.3 * sin((i.uv.y * _FlowDensity - _Time.y * _FlowSpeed) * 6.2831853);
                float f = pow(saturate(abs(dot(normalize(i.worldN), normalize(i.worldV)))), _Soft);
                float3 c = _Color.rgb * _Energy * pulse * (0.25 + 0.75 * f) * _Fade;
                return fixed4(c, 1);
            }
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
            Cull Off
            ZWrite Off
            Blend One One
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #include "UnityCG.cginc"
            float4 _Color;
            float _Energy, _FlowSpeed, _FlowDensity, _Soft, _Fade;
            struct appdata { float4 vertex : POSITION; float3 normal : NORMAL; float2 uv : TEXCOORD0; };
            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldN : TEXCOORD1;
                float3 worldV : TEXCOORD2;
            };
            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldN = UnityObjectToWorldNormal(v.normal);
                o.worldV = _WorldSpaceCameraPos - worldPos;
                return o;
            }
            fixed4 frag(v2f i) : SV_Target
            {
                float pulse = 0.7 + 0.3 * sin((i.uv.y * _FlowDensity - _Time.y * _FlowSpeed) * 6.2831853);
                float f = pow(saturate(abs(dot(normalize(i.worldN), normalize(i.worldV)))), _Soft);
                float3 c = _Color.rgb * _Energy * pulse * (0.25 + 0.75 * f) * _Fade;
                return fixed4(c, 1);
            }
            ENDCG
        }
    }
    FallBack Off
}
