Shader "Unity Shaders Book/Chapter 7/Mask Texture"{
    Properties{
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "Bump" {}
        _BumpScale ("Bump Scale", float) = 1
        _Specular ("Specular Color", Color) = (1, 1, 1, 1)
        _SpecularMask ("Specular Mask", 2D) = "white" {}
        _SpecularScale ("Specular Scale", float) = 1
        _Gloss ("Gloss", Range(8, 128)) = 20
    }
    SubShader{
        pass{
            Tags {"LightModel" = "ForwardBase"}

            CGPROGRAM

            #include "Lighting.cginc"

            #pragma vertex vert
            #pragma fragment frag

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float _BumpScale;
            fixed4 _Specular;
            sampler2D _SpecularMask;
            float _SpecularScale;
            float _Gloss;
            
            struct a2v{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD;
            };

            struct v2f{
                float4 pos : SV_POSITION;
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
                float2 uv : TEXCOORD3;
            };

            v2f vert(a2v v){
                v2f f;
                f.pos = UnityObjectToClipPos(v.vertex);

                float3 bitangent = cross(v.normal, v.tangent.xyz) * v.tangent.w;

                f.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

                float3x3 rotation = float3x3(v.tangent.xyz, bitangent, v.normal);

                f.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex));
                f.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)); 

                return f;
            }

            fixed4 frag(v2f f) : SV_TARGET{
                float3 tangentNormal = UnpackNormal(tex2D(_BumpMap, f.uv));
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1 - saturate(dot(tangentNormal.x, tangentNormal.x)));

                fixed3 albedo = _Color.rgb * tex2D(_MainTex, f.uv).rgb;
                fixed3 ambient = albedo * UNITY_LIGHTMODEL_AMBIENT;
                fixed3 diffuse = albedo * _LightColor0.rgb * max(0, dot(tangentNormal, f.lightDir));

                half3 halfDir = normalize(normalize(f.viewDir) + normalize(f.lightDir));
                fixed3 specular = _Specular.rgb * _LightColor0.rgb * pow(max(0, dot(halfDir, tangentNormal)), _Gloss) * 
                                tex2D(_SpecularMask, f.uv).r * _SpecularScale;
                fixed3 color = ambient + diffuse + specular;
                return fixed4(color, 1);
            }

            ENDCG
        }
    }
    Fallback "Specular"
}