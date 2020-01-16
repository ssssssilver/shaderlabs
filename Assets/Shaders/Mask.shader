Shader "Unlit/MaskShader"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_MaskTex("Texture", 2D) = "white" {}
		_Radius("Radius",Range(0,1))=0.5
		_Pow("Power",Range(0.01,0.2))=0.1
	}
	SubShader
	{
		Tags{ "Queue" = "Transparent" }
		LOD 100
		ZWrite Off
	Pass
	{
		Blend SrcAlpha OneMinusSrcAlpha
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag

		#include "UnityCG.cginc"

	struct appdata
	{
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
	};

	struct v2f
	{
		float2 uv : TEXCOORD0;
		float4 vertex : SV_POSITION;
		float4 cicle:TEXCOORD1;
	};

	sampler2D _MainTex;
	sampler2D _MaskTex;
	fixed _Radius;
	fixed _Pow;

	v2f vert(appdata v)
	{
		v2f o;
		o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
		o.uv = v.uv;
		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		fixed4 col = tex2D(_MainTex, i.uv);
		//如果有遮罩图的话 可以直接使用遮罩图的a通道来当作输出
		//fixed4 mask = tex2D(_MaskTex,i.uv);
		//col.a *= mask.a;
		//return col;

		//======================================

		//如果没有遮罩图 可以自己定义简单图形的遮罩图
		//以正中为圆心 根据距离画圆
		float dis = distance(fixed2(0.5,0.5),i.uv);
		//小于圆半径返回1 大于半径返回0
 		float o = step(dis, _Radius);
		col.a=o*pow(dis, _Pow)* (_Radius-dis);
		return col;

	}
		ENDCG
	}
	}
}