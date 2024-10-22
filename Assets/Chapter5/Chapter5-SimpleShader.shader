// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter5/SimpleShader"{
	Properties{
		_Color ("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
		_Slider ("Pos offset", Range(-1.0, 1.0)) = 0
	}
	SubShader{
		Pass{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			fixed4 _Color;
			half _Slider;

			struct a2v{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f{
				float4 pos : SV_POSITION;
				float3 color : COLOR0;
			};

			v2f vert(a2v v){
				// return UnityObjectToClipPos(v.vertex);
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex + fixed4(v.normal, 0.0) * _Slider);
				o.color = v.normal * 0.5 + fixed3(0.5, 0.5, 0.5);
				return o;
			}

			fixed4 frag(v2f vf) : SV_Target{ //system value render target == color
				// return fixed4(1.0, 1.0, 1.0, 1.0);
				// return fixed4(sp.xy / _ScreenParams.xy, 0.0, 1.0);//sp 面片所在的像素位置，_ScreenParams分辨率::fixed4 frag(float4 sp : WPOS) : SV_Target{
				return fixed4(vf.color * _Color, 1.0);
			}

			ENDCG
		}
	}
}
