Shader "Unity Shaders Book/Chapter 11/Water"{
    Properties {
		_MainTex ("Main Tex", 2D) = "white" {}
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_Magnitude ("Distortion Magnitude", Float) = 1
 		_Frequency ("Distortion Frequency", Float) = 1
        _Fluctuation ("Fluctuation degree", Range(0.01, 0.1)) = 0.05
 		_InvWaveLength ("Distortion Inverse Wave Length", Float) = 10
 		_Speed ("Speed", Float) = 0.5 
	}
    SubShader
    {
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "DisableBatching"="True" }

        pass{
            Tags { "LightMode" = "ForwardBase" }

            ZWrite Off 
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            float _Magnitude;
            float _Frequency;
            float _InvWaveLength;
            float _Speed;
            float _Fluctuation;

            struct a2v {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
            };
            
            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD1;
            };

            v2f vert(a2v v){
                v2f o;
                float4 offset = float4(0, 0, 0, 0);
                offset.yzw = float3(0, 0, 0);
                // offset.x = 1;
				offset.x = sin(_Frequency * _Time.y + v.vertex.z * _InvWaveLength + v.vertex.x * 5) * _Magnitude + _Fluctuation * sin( _Time.y);

                o.pos = UnityObjectToClipPos(v.vertex + offset);

                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex) + float2(0, _Time.y * _Speed); // ??

                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET{
                fixed4 c = tex2D(_MainTex, i.uv);
                c.rgb *= _Color.rgb;
                return c;
            }

            ENDCG
        }
    }
    FallBack "Transparent/VertexLit"
}
