Shader "Unity Shaders Book/Chapter6/Diffuse Vertex-Level"{
    Properties{
        _Diffuse ("Diffuse Color", Color) = (1.0, 1.0, 1.0, 1.0)
    }
    SubShader{
        Pass{
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            fixed4 _Diffuse;

            struct a2v{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f{
                float4 pos : SV_POSITION;
                fixed3 color : COLOR;
            };

            v2f vert(a2v v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 worldNormal = normalize(mul((float3x3)UNITY_MATRIX_M, v.normal));
                // fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 diffuse = _Diffuse.rgb * _LightColor0.rgb * saturate(dot(worldLight, worldNormal));
                o.color = diffuse + ambient;
                return o;
            }

            fixed4 frag(v2f vf) : SV_TARGET{
                return fixed4(vf.color, 1.0);
            }

            ENDCG
        }
    }
    Fallback "Diffuse"
}