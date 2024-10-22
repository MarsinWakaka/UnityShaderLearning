Shader "Unity Shaders Book/Chapter 12/m_motionBlur"
{
    Properties{
		//_MainTex即传入的图像，此方案中这个对应的是这一帧的画面
		// 返回的结果将写入帧缓冲，由CS文件的Blit将帧缓冲复制到accumulationTexture上
		// 也就是说现在帧缓冲里实际上是上一帧的画面
        _MainTex ("Base(RGB)", 2D) = "white"{}
        _BlurAmount( "BlurAmount", float) = 1.0
    }

    SubShader{
		CGINCLUDE
		
		#include "UnityCG.cginc"
		
		sampler2D _MainTex;
		fixed _BlurAmount;
		
		struct v2f {
			float4 pos : SV_POSITION;
			half2 uv : TEXCOORD0;
		};
		
		v2f vert(appdata_img v) {
			v2f o;
			
			o.pos = UnityObjectToClipPos(v.vertex);
			
			o.uv = v.texcoord;
					 
			return o;
		}
		
		// Blend SrcAlpha OneMinusSrcAlpha
		// ColorMask RGB
		half4 fragRGB (v2f i) : SV_Target {

			// return Half4(当前帧的RGB, _BlurAmount);
			return fixed4(tex2D(_MainTex, i.uv).rgb, _BlurAmount);
			// 由于开启了混合并且不透明度为_BlurAmount( < 1) 
			// 假设通过深度测试后(也就是确认看得到后)将与已有的帧缓冲里的颜色进行混合
			// 我们这里是将当前帧 与 上一帧的图像 混合，具体是因为motionBlur.cs文件里的Graphics.Blit (src, accumulationTexture, material);
			// Shader里的BlurAmount值越小，当前帧的占比越低，随之 动态模糊 效果越明显
			// 最终图像颜色为 _BlurAmount * 当前帧(_MainTex) + (1 - _BlurAmount) * 上一帧的画面(accumulationTexture, 注意这里的上一帧画面是经过同样处理后，最终呈现的画面)
			// 由于 ColorMask RGB, 所以帧缓冲里的颜色值被改变，但是透明度通道信息不变
		}
		// 所以此Pass结束后帧缓冲里的颜色数据 记作 Pass1 = half4(混合后的R,G,B, accumulationTexture(上一帧结束时画面)的Alpha)
		// 注意事项 此Pass只是将当前帧 按比例 与上一帧进行混合，结果存储在帧缓冲中，返回的结果还没有写入 accumulationTexture
		

		// Blend One Zero
		// ColorMask A
		// 这里就只是采集当前帧的Alpha
		half4 fragA (v2f i) : SV_Target {
			return tex2D(_MainTex, i.uv);
		}
		// 所以此Pass结束后帧缓冲里的颜色数据 记作Pass2 = Half4(Pass1的R,G,B, 混合前时当前帧的Alpha);
		// 返回的结果写入 accumulationTexture
		// 最后CS文件中执行Graphics.Blit(accumulationTexture, dest);用于呈现
		
		ENDCG
		
		ZTest Always Cull Off ZWrite Off
		
		Pass {
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMask RGB
			
			CGPROGRAM
			
			#pragma vertex vert  
			#pragma fragment fragRGB  
			
			ENDCG
		}

// 	以下是为什么最好保留第二个Pass的一些原因：

// 正确性：第二个Pass用于采集当前帧的Alpha值并将其存储在颜色缓冲的Alpha通道中。如果省略第二个Pass，可能会导致渲染不透明物体的Alpha通道保留上一帧的Alpha值，从而可能导致不正确的混合或遮挡行为。

// 稳妥性：保留第二个Pass是一种稳妥的做法，以适应可能出现的不透明度变化和特殊效果。这可以确保Shader在更广泛的场景下都能正确工作。

// 后续修改和维护：如果以后需要对Shader进行修改或添加其他特效，保留第二个Pass可以使代码更容易维护和扩展，而不需要回头解决Alpha通道问题。

// 总之，虽然有时候省略第二个Pass可能不会立即引发问题，但为了保证渲染的正确性和一致性，建议保留第二个Pass，以便采集和更新Alpha通道的数据。这可以确保Shader在各种情况下都能正常工作。

		Pass {   
			Blend One Zero
			ColorMask A
			   	
			CGPROGRAM  
			
			#pragma vertex vert  
			#pragma fragment fragA
			  
			ENDCG
		}
	}
 	FallBack Off
}