Shader "Unity Shaders Book/Chapter 12/m_BrightnessSaturationAndContrast" {

    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Brightness ("Brightness", Float) = 1
        _Saturation ("Saturation", Float) = 1
        _Contrast ("Contrast", Float) = 1
    }
    SubShader
    {
        ZWrite Off
        Cull Off 
        ZTest Always //因为要显示在最前面，肯定要判断是不是在最前面,但是不能对之后的透明物体的渲染造成影响

        pass{
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag 

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            Float _Brightness;
            Float _Saturation;
            Float _Contrast;

            struct v2f{
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD;
            };

            v2f vert(appdata_img v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET{
                //亮度处理
                fixed4 renderTex = tex2D(_MainTex, i.uv);
                fixed3 finalColor = renderTex.rgb * _Brightness;
                
                //饱和度处理
                fixed luminance = 0.2125 * renderTex + 0.7154 * renderTex.g + 0.0721 * renderTex.b;
                fixed3 luminanceColor = fixed3(luminance, luminance, luminance);
                finalColor = lerp(luminanceColor, finalColor, _Saturation);

                //对比度处理
                fixed3 avgColor = fixed3(0.5, 0.5, 0.5);
                finalColor = lerp(avgColor, finalColor, _Contrast);
                // _contrast值为1时，即默认颜色
                // finalColor.rgb = _Contrast * avgColor + (1 - _Contrast) * finalColor.rgb;

                return fixed4(finalColor, renderTex.a);
            }
            
            ENDCG
        }
    }
    FallBack Off
}
