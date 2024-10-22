// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 7/Normal Map In Tangent Space"{
    Properties{
        _Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _MainTex ("Texture", 2D) = "White" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _BumpScale ("Bump Scale", float) = 1.0
        _Specular ("Specular", Color) = (1.0, 1.0, 1.0, 1.0)
        _Gloss ("Gloss", Range(8, 128)) = 20
    }
    SubShader{
        pass{
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            fixed4 _Specular;
            float _Gloss;

            struct a2v{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD;
            };

            struct v2f{
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD2;
                float3 lightDir : TEXCOORD0;
                float3 viewDir : TEXCOORD1;
            };

            v2f vert(a2v v){
                v2f o;
                // compute worldspace vertexPos
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

                float3 bitangent = cross(v.normal, v.tangent.xyz) * v.tangent.w;
                float3x3 rotation = float3x3(v.tangent.xyz, bitangent, v.normal);
                // TANGENT_SPACE_ROTATION;

                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
                o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;

                return o;
            }
            
            // 计算方式没变，只是将一切的计算转化到了切线空间下进行
            fixed4 frag(v2f f) : SV_TARGET{
                float3 tangentLightDir = normalize(f.lightDir);
                float3 tangentViewDir = normalize(f.viewDir);

                float4 packedNormal = tex2D(_BumpMap, f.uv.zw);
                
                // 法向量分量的范围在[-1, 1]之间，而RGB的分量在[0, 1]之间，所以要以图片的形式存储的话需要映射到RGB颜色范围内，所以采样结果是RGB颜色范围，
                // 我们需要对其进行重新映射，也就是解包UnpackNormal函数。将其重新映射到[-1, 1]之间
                float3 tangentNormal = UnpackNormal(packedNormal);
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1 - dot(tangentNormal.xy, tangentNormal.xy));

                float3 albedo = tex2D(_MainTex, f.uv.xy).rgb * _Color.rgb;

                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                float3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));

                fixed3 halfDir = normalize(tangentViewDir + tangentLightDir);
                float3 specular = _Specular.rgb * _LightColor0.rgb * pow(max(0, dot(halfDir, tangentNormal)), _Gloss);

                fixed3 color = ambient + diffuse + specular;
                return fixed4(color, 1.0);
            }

            ENDCG
        }
    }
    Fallback "Specular"
}