Shader "Unity Shaders Book/Chapter 11/Scrolling Background"{
    Properties
    {
        _MainTex ("Base Layer", 2D) = "white" {}
        _DetailTex ("2nd Layer", 2D) = "white" {}
        _ScrollX ("Base Layer Scroll Speed", float) = 0.1
        _Scroll2X ("2nd Layer Scroll Speed", float) = 0.06
        _Multiplier ("Layer Multiplier", Float) = 1

    }
    SubShader
    {
        Tags { "Queue"="Geometry" "RenderType"="Opaque" }

        pass{
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            
            sampler2D _MainTex;
            sampler2D _DetailTex;
            float4 _MainTex_ST;
            float4 _DetailTex_ST;
            float _ScrollX;
            float _Scroll2X;
            float _Multiplier;

            struct a2v {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
            };
            
            struct v2f {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
            };

            v2f vert(a2v v){
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex) + float2(frac(_Time.y * _ScrollX), 0.0);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _DetailTex) + float2(frac(_Time.y * _Scroll2X), 0.0);

                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET{
                fixed4 MainColor = tex2D(_MainTex, i.uv.xy);
                fixed4 DetailColor = tex2D(_DetailTex, i.uv.zw);
                return fixed4(lerp(DetailColor, MainColor, MainColor.a) * _Multiplier);
            }

            ENDCG
        }
    }
    FallBack "VertexLit"
}
