Shader "Unity Shaders Book/Chapter8/Alpha Blend ZWrite"{
    Properties{
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _AlphaScale ("Alpha Cutout", Range(0, 1)) = 1
    }
    SubShader{
        Tags{
            "Queue" = "Transparent"
            "IngoreProjector" = "True"
            "RenderType" = "Transparent"
        }
        // Extra pass that renders to depth buffer only

        Pass {
            ZWrite On
            ColorMask 0
        }

        Pass{
            Tags { "LightModel" = "ForwardBase" }
            
            ZWrite Off
            // 名字是固定的,Minus是减的意思

            // One, Zero
            // SrcColor：源像素的颜色值。
            // SrcAlpha：源像素的透明度值（alpha值）。
            // OneMinusSrcColor：（1 - 源像素的颜色值）。
            // OneMinusSrcAlpha：（1 - 源像素的透明度值）。
            // DstColor：目标像素的颜色值（通常是背景像素的颜色值）。
            // DstAlpha：目标像素的透明度值（通常是背景像素的透明度值）。
            // OneMinusDstColor：（1 - 目标像素的颜色值）。
            // OneMinusDstAlpha：（1 - 目标像素的透明度值）。
            Blend SrcAlpha OneMinusSrcAlpha

            // Cull Off

            CGPROGRAM

            #include "Lighting.cginc"

            #pragma vertex vert
            #pragma fragment frag

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _AlphaScale;

            struct a2v{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD;
            };

            struct v2f{
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
            };

            v2f vert(a2v v){
                v2f f;
                f.pos = UnityObjectToClipPos(v.vertex);
                f.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                f.worldPos = mul(UNITY_MATRIX_M, v.vertex);
                f.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));

                return f;
            }

            fixed4 frag(v2f f) : SV_TARGET{
                float3 lightDir = normalize(UnityWorldSpaceLightDir(f.worldPos));

                fixed4 texColor = tex2D(_MainTex, f.uv);

                float3 albedo = _Color.rgb * texColor.rgb;

                fixed3 ambient = albedo * UNITY_LIGHTMODEL_AMBIENT;

                fixed3 diffuse = albedo * _LightColor0.rgb * max(0, dot(lightDir, f.worldNormal));

                return fixed4(ambient + diffuse, texColor.a * _AlphaScale);
            }

            ENDCG
        }
    }
    Fallback "Transparent/VertexLit"
}