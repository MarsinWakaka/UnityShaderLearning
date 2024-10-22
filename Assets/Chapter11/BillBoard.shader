// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unity Shaders Book/Chapter 11/BillBoard"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _VerticalBillboarding ( "Vertical Restraints", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "IgnoreProjector" = "True" "Queue" = "Transparent" "DisableBatching" = "True"}
        
        pass{
            Tags { "LightMode" = "ForwardBase" }

            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off 

            CGPROGRAM

            #include "UnityCG.cginc"

            #pragma vertex vert
            #pragma fragment frag 

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            float _VerticalBillboarding;

            struct a2v{
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD;
            };

            struct v2f{
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD;
            };

            v2f vert(a2v v){
                v2f o;

                // o.pos = UnityObjectToClipPos(v.vertex);
                // o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

                // float3 center = float3(0, 0, 0); //z 前后, x左右 y上下
                // float3 viewer = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));

                // float3 normalDir = viewer - center;
                // normalDir.y *= _VerticalBillboarding;
                // normalDir = normalize(normalDir);

                // // float3 upDir = normalDir.y > 0.999 ? float3(0, 0, 1) : float3(0, 1, 0);
                // float3 upDir = float3(0, 1, 0); //要注意相机正好位于BillBoard上方时，BillBoard会消失
                // float3 rightDir = normalize(cross(upDir, normalDir));
                // upDir = cross(normalDir, rightDir);

                // float3 offset = v.vertex - center;
                // o.pos = UnityObjectToClipPos(center + offset.x * rightDir + offset.y * upDir + offset.z * normalDir + float3(0, sin(_Time.z) / 4, 0));

                // 舍弃了某些可读性，优化性能的代码
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

                float3 viewerPos = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));

                float3 normalDir = viewerPos;
                normalDir.y *= _VerticalBillboarding;
                normalDir = normalize(normalDir);

                // float3 upDir = float3(0, 1, 0); //要注意相机正好位于BillBoard上方时，BillBoard会消失，解决方法参考以上或以下代码

                float3 upDir = float3(0, 1, 0.0001); //要注意相机正好位于BillBoard一定角度时，BillBoard会消失，不过这个角度几乎不可能达成
                float3 rightDir = normalize(cross(upDir, normalDir));
                upDir = cross(normalDir, rightDir);

                float3 offset = v.vertex.xyz;
                o.pos = UnityObjectToClipPos(offset.x * rightDir + offset.y * upDir + offset.z * normalDir + float3(0, sin(_Time.z) / 4, 0));


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