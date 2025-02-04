Shader "Unity Shaders Book/Chapter8/Alpha Blend"{
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

		// Pass {
		// 	ZWrite On
		// 	ColorMask 0
		// }

        Pass{
            Tags { "LightModel" = "ForwardBase" }
            
            ZWrite Off
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