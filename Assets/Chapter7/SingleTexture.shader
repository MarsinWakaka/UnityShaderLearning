Shader "Unity Shaders Book/Chapter 7/Single Texture"{
    Properties{
        _Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _MainTex ("Texture", 2D) = "White"{}
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
            fixed4 _Specular;
            float _Gloss;

            struct a2v{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD;
            };

            struct v2f{
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float4 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            v2f vert(a2v av){
                v2f o;
                o.pos = UnityObjectToClipPos(av.vertex);
                o.worldNormal = normalize(UnityObjectToWorldNormal(av.normal));
                o.worldPos = mul(UNITY_MATRIX_M, av.vertex);
                // o.uv = TRANSFORM_TEX(av.texcoord, _MainTex);
                o.uv = av.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                return o;
            }

            fixed4 frag(v2f vf) : SV_TARGET{
                fixed3 albedo = tex2D(_MainTex, vf.uv).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;

                fixed3 worldLightDir = normalize(WorldSpaceLightDir(vf.worldPos));
                fixed3 diffuse = albedo * _LightColor0.rgb * max(0, dot(worldLightDir, vf.worldNormal));

                fixed3 viewDir = normalize(WorldSpaceViewDir(vf.worldPos));
                fixed3 halfDir = normalize(viewDir + worldLightDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(halfDir, vf.worldNormal)), _Gloss);
                
                fixed3 color = ambient + diffuse + specular;
                return fixed4(color, 1.0);
            }

            ENDCG
        }
    }
    Fallback "Specular"
}