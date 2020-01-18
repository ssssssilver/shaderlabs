Shader "Unlit/Flag"
{
	Properties
	{
		_Color("Color",color) = (1,1,1,1)
		_Wind("Wind",range(1,20)) = 1
		_Smooth("Smooth",range(0,1)) = 0.1
		_Range("Range",range(1,50))=10
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" "DisableBatching"="true" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			fixed4 _Color;
			fixed _Wind;
			fixed _Range;
			fixed _Smooth;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 pos : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				fixed z = sin(v.vertex *_Smooth + (_Time.y*_Wind))*(1-v.uv.x)* _Range;
				fixed4 vertex = v.vertex + fixed4(0,0,z,0);
				o.pos = mul(UNITY_MATRIX_MVP, vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return _Color;
			}
			ENDCG
		}
	}
}
