Shader "Unity Shaders Book/Chapter 14/My Toon Shading"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_Ramp ("Ramp Texture", 2D) = "white" {}
		_Outline ("Outline", Range(0, 1)) = 0.1
		_OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
		_Specular ("Specular", Color) = (1, 1, 1, 1)
		_SpecularScale ("Specular Scale", Range(0, 0.1)) = 0.01
    }
    SubShader
    {
        Tags{
            "RenderType" = "Opaque" "Queue" = "Geometry"
        }
        Pass{
            Name "OUTLINE"

            Cull Front

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float _Outline;
			fixed4 _OutlineColor;

            struct a2v{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f{
                float4 pos : SV_POSITION;
            };

            v2f vert(a2v v){
                v2f o;

                float4 pos = mul(UNITY_MATRIX_MV, v.vertex);
                float3 viewNormal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal); 
                viewNormal.z = -0.5;
                pos = pos + float4(_Outline * normalize(viewNormal), 0);
                o.pos = mul(UNITY_MATRIX_P, pos);
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET{
                return _OutlineColor;
            }

            ENDCG
        }

        Pass{
            Tags { "LightMode"="ForwardBase" }

            Cull Back

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _Ramp;
            float4 _Specular;
            float _SpecularScale;

            struct a2v{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
                // 这里是否需要tangent？
				float4 tangent : TANGENT;
            };

            struct v2f{
                float4 pos : SV_POSITION;
                float uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2; 
                SHADOW_COORDS(3)
            };
            // 读取顶点数据

            v2f vert(a2v v){
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.worldNormal  = normalize(UnityObjectToWorldNormal(v.normal));
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

                TRANSFER_SHADOW(o);

                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET{
                fixed3 worldNormal = i.worldNormal;
                float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                float3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 worldHalfDir = normalize(worldLightDir + worldViewDir);
                
                fixed3 albedo = tex2D(_MainTex, i.uv) * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

                fixed diff = dot(worldLightDir, worldNormal);
                diff = (diff / 2 + 0.5) * atten;
                fixed3 diffuse = tex2D(_Ramp, fixed2(diff, 0)).rgb * albedo * _LightColor0.rgb;

                fixed spec = dot(worldNormal, worldHalfDir);
                // fwidth用于计算相邻像素 的 传入参数 的差异
                fixed w = fwidth(spec) * 2;
                fixed3 specular = _Specular.rgb * lerp(0, 1, smoothstep(-w, w, spec + _SpecularScale - 1));

                // return fixed4(specular, 0);
                return fixed4(ambient + diffuse + specular, 0);
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}
