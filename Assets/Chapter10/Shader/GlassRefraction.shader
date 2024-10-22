// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 10/Glass Refraction" {
    Properties{
        _MainTex ("Main Tex", 2D) = "White" {}
        _BumpMap ("Normal", 2D ) = "White" {}
        _CubeMap ("Cubemap", Cube) = "_Skybox" {}
        _Distortion ("Distortion", Range(0, 100)) = 10
        _RefractionAmount ("Refraction Amount", Range(0, 1)) = 0.5
    }
    SubShader{
        Tags { "Queue" = "Transparent" "RenderType" = "Opaque" }

        GrabPass { "_RefractionTex" }

        Pass{
            CGPROGRAM

            // #include "Lighting.cginc"
            #include "UnityCG.cginc"

            // #pragma mutil_compile_fwdbase

            #pragma vertex vert 
            #pragma fragment frag 

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            samplerCUBE _CubeMap;
            float _Distortion;
            fixed _RefractionAmount;
            sampler2D _RefractionTex;
            float4 _RefractionTex_TexelSize;

            struct a2v{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f{
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD1;
                float4 TtoW0 : TEXCOORD2;
                float4 TtoW1 : TEXCOORD3;
                float4 TtoW2 : TEXCOORD4;
                float4 scrPos : TEXCOORD5;
            };

            v2f vert(a2v v){
                // v2f o;
				// o.pos = UnityObjectToClipPos(v.vertex);
				
				// o.scrPos = ComputeGrabScreenPos(o.pos);
				
				// o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				// o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);
				
				// float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;  
				// fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);  
				// fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);  
				// fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w; 
				
				// o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);  
				// o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);  
				// o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);  
				
				// return o;

                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
				
				o.scrPos = ComputeGrabScreenPos(o.pos);
				
				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;  
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);  
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);  
                float3 worldBiTangent = cross(worldNormal, worldTangent) * v.tangent.w;

                o.TtoW0 = float4(worldTangent.x, worldBiTangent.x, worldNormal.x, worldPos.x);
                o.TtoW1 = float4(worldTangent.y, worldBiTangent.y, worldNormal.y, worldPos.y);
                o.TtoW2 = float4(worldTangent.z, worldBiTangent.z, worldNormal.z, worldPos.z);

                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET{
                float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                fixed3 viewDir = UnityWorldSpaceViewDir(worldPos);

                fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
                float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
                i.scrPos.xy = i.scrPos.xy + offset;
                fixed3 refrCol = tex2D(_RefractionTex, i.scrPos.xy / i.scrPos.w).rgb;

                bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
                fixed3 reflDir = reflect(-viewDir, bump);
                fixed3 reflCol = texCUBE(_CubeMap, reflDir) * tex2D(_MainTex, i.uv.xy).rgb;

                return fixed4(_RefractionAmount * refrCol + (1 - _RefractionAmount) * reflCol, 1);
            }

            ENDCG

        }
    }
}
