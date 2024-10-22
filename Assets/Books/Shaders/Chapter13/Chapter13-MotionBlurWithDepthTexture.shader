// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 13/Motion Blur With Depth Texture" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_BlurSize ("Blur Size", Float) = 1.0
	}
	SubShader {
		CGINCLUDE
		
		#include "UnityCG.cginc"
		
		sampler2D _MainTex; //存放在TEXCOORD0
		float4 _MainTex_TexelSize;
		sampler2D _CameraDepthTexture; //存放在TEXCOORD1
		float4x4 _CurrentViewProjectionInverseMatrix;
		float4x4 _PreviousViewProjectionMatrix;
		half _BlurSize;
		
		struct v2f {
			float4 pos : SV_POSITION;
			half2 uv : TEXCOORD0;
			half2 uv_depth : TEXCOORD1;
		};
		
		v2f vert(appdata_img v) {
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
		
		fixed4 frag(v2f i) : SV_Target {
			// Get the depth buffer value at this pixel.
			float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth);

			// 乐乐女神 代码没有的地方
			#if defined(UNITY_REVERSED_Z)       //宏定义：是否进行了深度取反
                d = 1.0 - d;
            #endif

			// H is the viewport position at this pixel in the range -1 to 1.
			float4 H = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1, d * 2 - 1, 1);

			if(H.z > 0.9)
				return tex2D(_MainTex, i.uv);

			// Transform by the view-projection inverse.
			float4 D = mul(_CurrentViewProjectionInverseMatrix, H);
			// Divide by w to get the world position.
			float4 worldPos = D / D.w;

			
			// Current viewport position 
			float4 currentPos = H;
			// Use the world position, and transform by the previous view-projection matrix.  
			float4 previousPos = mul(_PreviousViewProjectionMatrix, worldPos);
			// Convert to nonhomogeneous points [-1,1] by dividing by w.
			previousPos /= previousPos.w;
			
			// Use this frame's position and last frame's to compute the pixel velocity.
			float2 velocity = (currentPos.xy - previousPos.xy)/2.0f;
			
			// 左下角为起点
			float2 uv = i.uv;

			float4 c = tex2D(_MainTex, uv);
			uv -= velocity * _BlurSize;
			// uv-=则为拖影， +=则预先
			for (int it = 1; it < 3; it++, uv -= velocity * _BlurSize) {
				float4 currentColor = tex2D(_MainTex, uv);
				c += currentColor;
			}
			c /= 3;
			
			return fixed4(c.rgb, 1);
		}
		
		ENDCG
		
		Pass {      
			ZTest Always Cull Off ZWrite Off
			    	
			CGPROGRAM  
			
			#pragma vertex vert  
			#pragma fragment frag  
			  
			ENDCG  
		}
	} 
	FallBack Off
}

// Shader "Unlit/C13_MotionBlurWithDepthMatrix"
// {
//     Properties
//     {
//         _MainTex ("RGB:Base", 2D) = "white" {}
//         _BlurSize ("模糊大小" , Float) = 0.5
//     }
//     SubShader
//     {
//         Tags { "RenderType"="Opaque" }
//         CGINCLUDE
//         #include "UnityCG.cginc"

//         sampler2D _MainTex;     float4 _MainTex_TexelSize;
//         sampler2D _CameraDepthTexture;      //Unity传递过来的深度纹理
//         float4x4 _PreviousViewProjectionMatrix;         //脚本传来：变化矩阵WS->NDC ,  前一帧的NDC位置
//         float4x4 _CurrentViewProjectionInverseMatrix;   //脚本传来：变化矩阵NDC->WS ,  当前帧的WS位置
//         half _BlurSize;

//         struct appdata {
//             float4 vertex : POSITION;
//             float2 uv0 : TEXCOORD0;
//         };

//         struct v2f {
//             float4 pos : SV_POSITION;
//             float2 uv0 :TEXCOORD0; 
//             float2 uv_depth :TEXCOORD1;  //用于采样深度纹理
//         };

//         v2f vert (appdata v) {
//             v2f o;
//             o.pos = UnityObjectToClipPos(v.vertex);
//             o.uv0 = v.uv0;
//             o.uv_depth = v.uv0;
            
//             #if UNITY_UV_STARTS_AT_TOP      //去除平台化差异，防止开启抗锯齿带来多个渲染纹理出现uv错误
//             if (_MainTex_TexelSize.y < 0)
//                 o.uv_depth.y = 1 - o.uv_depth.y;
//             #endif

//             return o;
//         }

//         half4 frag(v2f i) : SV_TARGET {
//             //【计算速度】
//             float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture , i.uv_depth);   //采样深度图，获取深度值
//             #if defined(UNITY_REVERSED_Z)       //宏定义：是否进行了深度取反
//                 d = 1.0 - d;
//             #endif

//             float4 H = float4(i.uv0.x*2 - 1 , i.uv0.y*2 - 1 ,  d*2 - 1 , 1);   //从深度值到NDC坐标

//             float4 D = mul(_CurrentViewProjectionInverseMatrix , H);       // NDC乘逆变换矩阵
//             float4 posWS = D / D.w;     // 获取世界空间坐标

//             float4 previousPos = mul(_PreviousViewProjectionMatrix , posWS);    //前一帧齐次裁剪坐标
//             previousPos /= previousPos.w;       //前一帧NDC坐标

//             float4 currentPos = H;      //当前帧NDC坐标

//             float2 velocity =(currentPos.xy - previousPos.xy) / 2.0f;   //速度范围[-1,1]

//             //【用速度偏移uv，进行采样】
//             float2 uv = i.uv0;
//             float4 c = tex2D(_MainTex , uv);
//             uv += velocity * _BlurSize;     //uv偏移
//             for (int it = 1 ; it < 3 ; it++ , uv += velocity * _BlurSize) {
//                 float4 currentCol = tex2D(_MainTex , uv);   //用新uv采样_MainTex
//                 c +=currentCol;     //c的颜色叠加
//             }
//             c /= 3;     //三次采样后的结果取平均

//             return half4(c.rgb , 1.0);
//         }

//         ENDCG

//         Pass
//         {
            
//             ZTest Always ZWrite Off Cull Off
//             CGPROGRAM
//             #pragma vertex vert
//             #pragma fragment frag
//             ENDCG
//         }
//     }
// }
