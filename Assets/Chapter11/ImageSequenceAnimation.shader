Shader "Unity Shaders Book/Chapter 11/ImageSequenceAnimation"{
    Properties{
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _HorizontalAmount ("Horizontal Amount", Float) = 8
        _VerticalAmount ("Vertical Amount", Float) = 8
        _Speed ("Animation Speed", Range(1, 100)) = 30
    }
    SubShader{
        Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }

        pass{
            Tags { "LightMode" = "ForwardBase" }

            Zwrite off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM

            #include "UnityCG.cginc"
            
            #pragma vertex vert
            #pragma fragment frag 

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _HorizontalAmount;
            float _VerticalAmount;
            float _Speed;

            struct a2v{
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f{
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD1;
            };

            v2f vert(a2v v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET{
                // float time = floor(_Time.y * _Speed) % (_HorizontalAmount * _VerticalAmount);
                // // 根据时间计算当前行数和列数
                // float row = floor(time / _HorizontalAmount);
                // float column = time - row * _HorizontalAmount;

                // //注意uv的原点在左下角,而随着time增加,row不再是0，那么v分量将会小于0，所以改为钳制将会出现竖状条纹
                // half2 uv = i.uv + half2(column, -row);
                
                // uv.y /= _VerticalAmount;
                // uv.x /= _HorizontalAmount;
                // uv.y = (uv.y + (_VerticalAmount - 1) / _VerticalAmount) % 1; //使序列图从左上角开始

                // float x = row / 8;
                // c.rgb = fixed3(x, x, x);
                // 最后8帧突然变黑,也就是说最黑的8帧出现在爆炸序列帧最后8帧(对应的就是最底下一行序列帧),原因就是序列动画是从左下角开始的

                // //fixed4 c = tex2D(_MainTex, uv);
                // //c.rgb *= _Color.rgb;
                // return c;

                
                // 冯乐乐
                float time = floor(_Time.y * _Speed);
                float row = floor(time / _HorizontalAmount);// 超过一定数量后因为uv的值超过1，由于材质设置为了repeat所以可以重复播放
                float column = time - row * _HorizontalAmount;

                // half2 uv = float2(i.uv.x / _HorizontalAmount, i.uv.y / _VerticalAmount);
                // uv.x += column / _HorizontalAmount;
                // uv.y -= row / _VerticalAmount;
                half2 uv = i.uv + half2(column, -row);
                uv.x /= _HorizontalAmount;
                uv.y /= _VerticalAmount;

                fixed4 c = tex2D(_MainTex, uv);

                
                c.rgb *= _Color.rgb;
                return c;
            }

            ENDCG
        }
    }
    Fallback "Transparent/VertexLit"
}
