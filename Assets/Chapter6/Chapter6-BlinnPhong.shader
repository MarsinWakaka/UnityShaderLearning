Shader "Unity Shaders Book/Chapter6/Specular Pixel-Level"{
    Properties{
        _Diffuse ("Diffuse Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _Specular ("Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _Gloss ("Gloss", Range(8, 128)) = 20
    }
    SubShader{
        Pass{
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct a2v{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f{
                float4 pos : SV_POSITION;
                fixed3 worldNormal : TEXCOORD0;
                fixed4 worldPos : TEXCOORD1;
            };

            v2f vert(a2v v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                o.worldPos = mul(UNITY_MATRIX_M, v.vertex);
                return o;
            }

            fixed4 frag(v2f vf) : SV_TARGET{
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(vf.worldPos));
                fixed3 diffuse = _Diffuse.rgb * _LightColor0.rgb * saturate(dot(worldLightDir, vf.worldNormal));

                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(vf.worldPos));
                fixed3 halfDir = normalize(viewDir + worldLightDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(dot(halfDir, vf.worldNormal), 0), _Gloss);
                return fixed4(fixed3(specular + diffuse + ambient), 1.0);
            }

            ENDCG
        }
    }
    Fallback "Specular"
}