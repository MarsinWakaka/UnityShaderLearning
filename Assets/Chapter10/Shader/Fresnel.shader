Shader "Unity Shaders Book/Chapter 10/Fresnel" {
    Properties{
        _Color ("Color Tint", Color) = (1, 1, 1 ,1)
        _FresnelScale ("Fresnel Scale", Range(0, 1)) = 0.5
        _Cubemap ("Cubemap", Cube) = "_Skybox" {}
    }
    SubShader{
        Tags { "RenderType"="Opaque" "Queue"="Geometry"}
        
        pass{
            Tags {"LightMode" = "ForwardBase"}
            
            CGPROGRAM

            #pragma multi_compile_fwdbase
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

            fixed4 _Color;
            float _FresnelScale;
            samplerCUBE _Cubemap;

            struct a2v{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f{
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD;
                float3 worldNormal : TEXCOORD1;
                float3 worldViewDir : TEXCOORD2;
                float3 worldRefl : TEXCOORD3;
                SHADOW_COORDS(4)
            };

            v2f vert(a2v v){
                v2f o;
				
				o.pos = UnityObjectToClipPos(v.vertex);
				
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				
				o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
				
				// Compute the reflect dir in world space
				o.worldRefl = reflect(-o.worldViewDir, o.worldNormal);
				
				TRANSFER_SHADOW(o);
				
				return o;
            }

            fixed4 frag(v2f i) : SV_TARGET{
                float3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                float3 worldViewDir = normalize(i.worldViewDir);
                float3 worldNormal = normalize(i.worldNormal);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

                fixed3 diffuse = _Color.rgb * _LightColor0.rgb * max(0, dot(lightDir, worldNormal));

                fixed3 reflection = texCUBE(_Cubemap, i.worldRefl).rgb;
                float fresnel = _FresnelScale + (1 - _FresnelScale) * pow(1 - dot(worldViewDir, worldNormal), 5);

                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
				
				// Mix the diffuse color with the reflected color
				fixed3 color = ambient + lerp(diffuse * atten, reflection, saturate(fresnel));
				
				return fixed4(color, 1.0);
            }

            ENDCG
        }
    }
    FallBack "Reflective/VertexLit"
}