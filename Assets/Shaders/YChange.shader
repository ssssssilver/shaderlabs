Shader "Unlit/YChange"

{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Texture", 2D) = "white" {}
		_AddColor("AddColor", Color) = (1, 1, 1, 1)
		_AddStart("AddStart", float) = 0
		_AddEnd("AddEnd", float) = 0
	}
		SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			fixed4 _Color;
			fixed4 _AddColor;
			half _AddStart;
			half _AddEnd;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			struct a2v
			{
				float4 vertex:POSITION;
				float2 uv:TEXCOORD0;
			};
			struct v2f
			{
				float4 pos:SV_POSITION;
				float2 uv:TEXCOORD0;
				float3 worldPos:TEXCOORD1;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				o.worldPos = mul(_Object2World,v.vertex);
				o.uv = TRANSFORM_TEX(v.uv,_MainTex);
				return o;
			}

			fixed4 frag(v2f i):SV_Target
			{
				fixed4 col = tex2D(_MainTex,i.uv)*_Color;
				//根据y轴来改变对应部分的颜色
				fixed offset= saturate((_AddStart - i.worldPos.y) / (_AddStart - _AddEnd));
				col.rgb = lerp(col.rgb, _AddColor, offset);
				return col;
			}
			ENDCG
		}

	}
		Fallback "Diffuse"
}