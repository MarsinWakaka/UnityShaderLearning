Shader "Unity Shaders Book/Chapter6/Diffuse Pixel-Level"{
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
                fixed3 worldNormal : COLOR;
            };

            v2f vert(a2v v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag(v2f vf) : SV_TARGET{
                fixed3 worldLight = _WorldSpaceLightPos0.xyz;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 diffuse = _Diffuse.xyz * _LightColor0.rgb * saturate(dot(vf.worldNormal, worldLight));
                fixed3 color = ambient + diffuse;
                return fixed4(color, 1.0);
            }

            ENDCG
        }
    }
    Fallback "Diffuse"
}