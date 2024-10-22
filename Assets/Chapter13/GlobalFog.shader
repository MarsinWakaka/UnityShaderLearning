Shader "Unity Shaders Book/Chapter 13/Fog"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _FogDensity ("Fog Density", Float) = 1.0
        _FogColor ("Fog Color", Color) = (1, 1, 1, 1)
        _FogStart ("Fog Start", Float) = 0.0
        _FogEnd ("Fog End", Float) = 1.0
    }
    SubShader
    {
        ZTest Always ZWrite Off Cull Off
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            
            float4x4 _FrustumCornersRay;
            
            sampler2D _MainTex;
            half4 _MainTex_TexelSize;
            sampler2D _CameraDepthTexture;
            half _FogDensity;
            fixed4 _FogColor;
            float _FogStart;
            float _FogEnd;
            
            struct v2f {
                float4 pos : SV_POSITION;
                half2 uv : TEXCOORD0;
                half2 uv_depth : TEXCOORD1;
                float4 interpolatedRay : TEXCOORD2;
            };

            v2f vert(appdata_img v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                
                // 为什么要分深度uv 和 普通uv
                o.uv = v.texcoord;
                o.uv_depth = v.texcoord;
                
                #if UNITY_UV_STARTS_AT_TOP
                    if (_MainTex_TexelSize.y < 0)
                    o.uv_depth.y = 1 - o.uv_depth.y;
                #endif
                
                int index = 0;
                if (v.texcoord.x < 0.5 && v.texcoord.y < 0.5) {
                    index = 0;
                    } else if (v.texcoord.x > 0.5 && v.texcoord.y < 0.5) {
                    index = 1;
                    } else if (v.texcoord.x > 0.5 && v.texcoord.y > 0.5) {
                    index = 2;
                    } else {
                    index = 3;
                }

                #if UNITY_UV_STARTS_AT_TOP
                    if (_MainTex_TexelSize.y < 0)
                    index = 3 - index;
                #endif
                
                // 问题1.这里o.interpolatedRay 只可能是 视锥体frustum 的 四条棱的方向 的其中一个
                o.interpolatedRay = _FrustumCornersRay[index];
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float linearDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth));
                float3 worldPos = i.interpolatedRay * linearDepth + _WorldSpaceCameraPos;
                // 线性深度，也就是世界坐标下的深度
                
                float fogDensity = (_FogEnd - worldPos.y) / (_FogEnd - _FogStart);
                fogDensity = saturate(fogDensity * _FogDensity);
                
                fixed4 finalColor = tex2D(_MainTex, i.uv);
                finalColor.rgb = lerp(finalColor.rgb, _FogColor.rgb, fogDensity);
                
                return finalColor;
            }
            ENDCG
        }
    }
}
