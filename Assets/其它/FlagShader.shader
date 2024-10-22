// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/Flag"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SwingTex ("旗帜飘动权重贴图", 2D) = "white" {}
        _SwingSpeed ("Swing Speed", Float) = 10
        _SwingAmount ("Swing Amount", Float) = 0.1
        _SwingCircle ("Swing Circle", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Cull Off
            // 应用透明效果
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #pragma target 3.0

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _SwingTex;
            float4 _SwingTex_ST;
            
            float _SwingSpeed;
            float _SwingAmount;
            float _SwingCircle;

            v2f vert (appdata v)
            {
                v2f o;
                
                v.uv = TRANSFORM_TEX(v.uv, _SwingTex);
                float4 swing = tex2Dlod(_SwingTex, v.uv.xyxy);
                v.vertex.y +=
                    sin((_Time.w * _SwingSpeed + v.vertex.x) * _SwingCircle) *
                    _SwingAmount * swing.r -
                    v.vertex.z * 0.1;
                o.vertex = UnityObjectToClipPos(v.vertex);

                // float4 worldPos = mul(UNITY_MATRIX_M, v.vertex);
                // v.uv = TRANSFORM_TEX(v.uv, _SwingTex);
                // float4 swing = tex2Dlod(_SwingTex, v.uv.xyxy);
                // worldPos.z +=
                //     sin(_Time.w * _SwingSpeed + worldPos.x * _SwingCircle + worldPos.y) *
                //     _SwingAmount * swing.r;
                // o.vertex = mul(UNITY_MATRIX_VP, worldPos);
                
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
