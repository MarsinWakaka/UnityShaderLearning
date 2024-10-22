Shader "Unity Shaders Book/Chapter 10/Mirror" {
    Properties{
        _MainTex("Render Texture", 2D) = "White" {}
    }
    SubShader{
        pass{
            Tags {"LightMode" = "ForwardBase"}
            
            CGPROGRAM

            #pragma multi_compile_fwdbase
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

            sampler2D _MainTex;

            struct a2v{
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD;
            };

            struct v2f{
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD5;
            };

            v2f vert(a2v v){
                v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.uv.x = 1 - o.uv.x;
				
				return o;
            }

            fixed4 frag(v2f i) : SV_TARGET{				
				return tex2D(_MainTex, i.uv);
            }

            ENDCG
        }
    }
    FallBack "Reflective/VertexLit"
}