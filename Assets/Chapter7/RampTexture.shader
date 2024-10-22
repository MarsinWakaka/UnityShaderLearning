Shader "Unity Shaders Book/Chapter 7/Ramp Texture" {
    Properties{
        _Color ("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
        _RampTex ("Ramp Texture", 2D) = "White"{}
        _Specular ("Specular Color", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8, 128)) = 20
    }
    SubShader{
        Pass{
            Tags {"LightModel" = "ForwardBase"}

            CGPROGRAM
            
            #include "Lighting.cginc"

            #pragma vertex vert
            #pragma fragment frag
            
            fixed4 _Color;
            sampler2D _RampTex;
            float4 _RampTex_ST;
            fixed4 _Specular;
            float _Gloss;

            struct a2v{
                float4 vertex : POSITION;
                fixed3 normal : NORMAL;
                float4 texcoord : TEXCOORD;    
            };

            struct v2f{
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            v2f vert(a2v v){
                v2f f;
                f.pos = UnityObjectToClipPos(v.vertex);
                f.worldPos = mul(UNITY_MATRIX_M, v.vertex);
                f.worldNormal = UnityObjectToWorldNormal(v.normal);
                f.uv = TRANSFORM_TEX(v.texcoord, _RampTex);
                return f;
            }

            fixed4 frag(v2f f) : SV_TARGET{
                float3 lightDir = UnityWorldSpaceLightDir(f.worldPos);
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * _Color.rgb;

                fixed halfLambert = 0.5 * dot(f.worldNormal, lightDir) + 0.5;
                fixed3 diffuse = _Color.rgb * tex2D(_RampTex, fixed2(halfLambert, halfLambert));

                float3 viewDir = normalize(UnityWorldSpaceViewDir(f.worldPos));
                float3 halfDir = normalize(viewDir + lightDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(f.worldNormal, halfDir)), _Gloss);
                fixed3 color = ambient + diffuse + specular;
                return fixed4(color, 1.0);
            }

            ENDCG
        }
    }
    Fallback "Specular"
}