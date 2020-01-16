Shader "Unlit/Sheep"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Sex("性别（0代表磁性，1代表雄性)",Int) = 0
		_Number("数字(1~10)",Int) = 0
		_EyeColor1("眼睛颜色1",Color) = (0,0,0,0)
		_EyeColor2("眼睛颜色2",Color) = (0,0,0,0)
		_NeckletColor("项圈颜色",Color) = (0,0,0,0)
	}
	SubShader
	{
		Tags {"RenderType"="ShadowCaster" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				float3 color : COLOR;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 uv2 : TEXCOORD2;
				float4 vertex : SV_POSITION;
				float3 color : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			int _Sex;//0代表是母的，1代表是公的
			int _Number;
			float4 _EyeColor1;
			float4 _EyeColor2;
			float4 _NeckletColor;

			v2f vert (appdata v)
			{
				v2f o;
			
				o.uv = v.uv;
				o.uv2 = v.uv2 + fixed2((_Number - 1) * 0.1,0);
				o.color =v.color;
				if(_Sex == 0)
				{
					if(v.color.b ==1)
					{
						v.vertex = float4(0,0,0,0);
					}
				}
				else 
				{
					if(v.color.r ==1)
					{
						v.vertex = float4(0,0,0,0);
					}
				}
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				return o;
			}
			inline float4 Pow3(float4 x)
			{
				return x * x * x;
			}
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);	
				fixed4 numberCol = tex2D(_MainTex,i.uv2);
				fixed4 col2 = col;

				if(col.a < 0.49)
				{
				   col2 = lerp(col.r * _NeckletColor * 2,1 - (1 - col.r) * (1 - _NeckletColor) * 2,floor(col.r + 0.5));
				}
				else if(col.a < 0.99)
				{
					fixed4 cc1 = lerp(col.r * _EyeColor1 * 2,1 - (1 - col.r) * (1 - _EyeColor1) * 2,floor(col.r + 0.5));
					fixed4 cc2 = lerp(col.r * _EyeColor2 * 2,1 - (1 - col.r) * (1 - _EyeColor2) * 2,floor(col.r + 0.5));
					col2 = lerp(cc1,cc2,0.5 + (col.r - 0.5) * 2);


				}
				
			

				return lerp(col2 ,Pow3(col) * numberCol,numberCol.a);
			}
			ENDCG
		}
	}
}
