Shader "Unlit/InnerGlow" {
    Properties {
		_MainTex("MainTex", 2D) = "white" {}
		_EdgeColor("EdgeColor", Color) = (0.5,0.5,0.5,1)
		_Edge("Edge", Range(0, 5)) = 0
		_Specular("Specular",color)=(1,1,1,1)
		_Pow("Power", Range(0, 5)) = 0

	   _Gloss("Gloss",Range(1,100))=10

    }
    SubShader {
        Tags {
            "RenderType"="Opaque"
        }
        LOD 200
        Pass {
            Name "ForwardBase"
            Tags {
                "LightMode"="ForwardBase"
            }
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
			#include "Lighting.cginc"

             float4 _EdgeColor;
             sampler2D _MainTex;
			 float4 _MainTex_ST;
			 float _Edge;
			 float _Pow;
			 float3 _Specular;
			 float _Gloss;

            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
            };
            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv: TEXCOORD0;
                float4 worldPos : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
            };
            v2f vert (a2v v) {
				v2f o;
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.worldNormal = mul(_Object2World,v.normal);
                o.worldPos = mul(_Object2World, v.vertex);
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                return o;
            }
            fixed4 frag(v2f i) : SV_Target {
                fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
				fixed4 col = tex2D(_MainTex,i.uv);
				//根据世界法线与视角的点积求出边界位置再与原来颜色叠加
				fixed3 finalColor = (col.rgb+((_EdgeColor.rgb*_Edge)*pow(1.0-max(0,dot(worldNormal, viewDir)), _Pow)));
				//return fixed4(finalColor,1);

				//根据需要添加高光
				fixed3 lightView = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 halfView = normalize(viewDir+ lightView);
				fixed3 specular = _LightColor0.rgb*_Specular*pow(saturate(dot(halfView, worldNormal)), _Gloss);
				return fixed4(finalColor+ specular,1);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
