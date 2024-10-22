Shader "Unity Shaders Book/Chapter 7/Normal Map In World Space"{
    Properties{
        _Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _MainTex ("Texture", 2D) = "White" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _BumpScale ("Bump Scale", float) = 1.0
        _Specular ("Specular", Color) = (1.0, 1.0, 1.0, 1.0)
        _Gloss ("Gloss", Range(8, 128)) = 20
    }
    SubShader{
        Pass{
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            fixed4 _Color;
            fixed4 _Specular;
            float _Gloss;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;

            struct a2v{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD;
            };

            struct v2f{
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float4 TtoW0 : TEXCOORD1;
                float4 TtoW1 : TEXCOORD2;
                float4 TtoW2 : TEXCOORD3;
            };

            v2f vert(a2v v){
                v2f f;
                f.pos = UnityObjectToClipPos(v.vertex);
                f.uv.xy = _MainTex_ST.xy * v.texcoord.xy + _MainTex_ST.zw;
                f.uv.zw = _BumpMap_ST.xy * v.texcoord.xy + _BumpMap_ST.zw;

                float3 worldPos = mul(UNITY_MATRIX_M, v.vertex).xyz;
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                fixed3 worldBiTangent = cross(worldNormal, worldTangent) * v.tangent.w;

                // 切线空间转世界空间的
                f.TtoW0 = float4(worldTangent.x, worldBiTangent.x, worldNormal.x, worldPos.x);
                f.TtoW1 = float4(worldTangent.y, worldBiTangent.y, worldNormal.y, worldPos.y);
                f.TtoW2 = float4(worldTangent.z, worldBiTangent.z, worldNormal.z, worldPos.z);

                return f;
            }

            fixed4 frag(v2f f) : SV_TARGET {
                float3 worldPos = float3(f.TtoW0.w, f.TtoW1.w, f.TtoW2.w);
                float3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                float3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));


                fixed3 Bump = UnpackNormal(tex2D(_BumpMap, f.uv.zw));
                Bump.xy *= _BumpScale;
                Bump.z = sqrt(1 - saturate(dot(Bump.xy, Bump.xy)));
                //                 float3x3 矩阵 * float3 向量：
                // 当 float3 向量在矩阵的右边时，它被视为一个列向量。
                // 当 float3 向量在矩阵的左边时，它被视为一个行向量。
                // 这里Bump被视作了列向量,与下面效果一致
                // float3x3 rotation = float3x3(f.TtoW0.xyz, f.TtoW1.xyz, f.TtoW2.xyz);
                // Bump = normalize(mul(rotation, Bump));
                Bump = normalize(half3(dot(f.TtoW0.xyz, Bump), dot(f.TtoW1.xyz, Bump), dot(f.TtoW2.xyz, Bump)));

                fixed3 albedo = _Color.rgb * tex2D(_MainTex, f.uv.xy).rgb;
                fixed3 ambient = albedo * UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 diffuse = albedo * _LightColor0.rgb * max(0, dot(worldLightDir, Bump));

                // Calculate half vector using the normalized sum of light and view directions
                fixed3 halfDir = normalize(worldLightDir + worldViewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(halfDir, Bump)), _Gloss);

                fixed3 color = ambient + diffuse + specular;
                return fixed4(color, 1.0);
            }


            ENDCG
        }
    }
    Fallback "Specular"
}