Shader "Unity Shaders Book/Chapter 13/motionBlur_baseOnVelocity"
{
    Properties{
        _MainTex("MainTex", 2D) = "White"{}
        _BlurSize("Blur Size", float) = 1.0
    }

    SubShader{
        CGINCLUDE

        #include "UnityCG.cginc"

        sampler2D _MainTex;
        float4 _MainTex_TexelSize;
        sampler2D _CameraDepthTexture;
        float _BlurSize;
        float4x4 _PreviousViewProjectionMatrix;
        float4x4 _CurrentViewProjectionInverseMatrix;

        struct v2f{
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;
            float2 uv_depth : TEXCOORD1;
        };

        v2f vert(appdata_img v){
            v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			
			o.uv = v.texcoord;
			o.uv_depth = v.texcoord;
			
			#if UNITY_UV_STARTS_AT_TOP
			if (_MainTex_TexelSize.y < 0)
				o.uv_depth.y = 1 - o.uv_depth.y;
			#endif
					 
			return o;
        }

        fixed4 frag(v2f i) : SV_TARGET{
            float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth);

            #if defined(UNITY_REVERSED_Z)       //宏定义：是否进行了深度取反
                d = 1.0 - d;
            #endif

            //当前ndc坐标
            float4 currentPos = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1, d * 2 - 1, 1);

            // if(currentPos.z > 0.9) return tex2D(_MainTex, i.uv);

            //当前ndc坐标对应的 世界坐标
            float4 worldPos = mul(_CurrentViewProjectionInverseMatrix, currentPos);
            worldPos /= worldPos.w;

            //当前ndc坐标对应的 世界坐标 所对应的上一帧的ndc坐标
            float4 previousPos = mul(_PreviousViewProjectionMatrix, worldPos);
            previousPos /= previousPos.w;

            float2 velocity = (currentPos.xy - previousPos.xy) / 4 * _BlurSize;
            float2 uv = i.uv;

            fixed4 c = tex2D(_MainTex, uv);
            uv -= velocity;

            for (int i = 1; i < 5; i++,uv -= velocity){
                fixed4 color = tex2D(_MainTex, uv);
                c += color;
            }

            c /= 5;
            return fixed4(c.rgb, 1);

            // float4 currentWorldPos = float4()
        } 

        ENDCG

        Pass{
            ZTest Always Cull Off ZWrite Off

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            ENDCG
        }
    }
    Fallback Off
}