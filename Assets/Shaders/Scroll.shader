Shader "Unlit/Scroll"
{
	Properties
	{
		_FrontTex("FrontTex", 2D) = "white" {}
		_BackTex("BackTex", 2D) = "white" {}
		_FrontSpeed("FrontSpeed",Range(0.1,10))=0
		_BackSpeed("BackSpeed",Range(0.1,10))=0
	}

		SubShader
	{
		Tags{ "Queue" = "Geometry" "IgnoreProjector" = "True" }

		Pass
	{

		CGPROGRAM
		#pragma vertex vert  
		#pragma fragment frag
		#include "UnityCG.cginc"

		sampler2D _FrontTex;
		float4 _FrontTex_ST;
		sampler2D _BackTex;
		float4 _BackTex_ST;
		float _FrontSpeed;
		float _BackSpeed;

		struct a2v
		{
			float4 vertex : POSITION;
			float2 texcoord : TEXCOORD0;
		};

		struct v2f
		{
			float4 pos : SV_POSITION;
			float4 uv : TEXCOORD0;

		};

	v2f vert(a2v v)
	{
		v2f o;
		o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
		o.uv.xy = TRANSFORM_TEX(v.texcoord, _FrontTex);
		o.uv.zw = TRANSFORM_TEX(v.texcoord, _BackTex);
		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		//调整uv 让背景不会过宽或过长
		fixed2 uvFront = fixed2(i.uv.x*2,i.uv.y);
		fixed4 front = tex2D(_FrontTex,(uvFront + fixed2(_Time.x*_FrontSpeed,0)));
		fixed2 uvBack = fixed2(i.uv.z/4,i.uv.w);
		fixed4 back = tex2D(_BackTex,(uvBack + fixed2(_Time.x*_BackSpeed,0)));
		//混合前后景 前景必须透明
		return lerp(back,front, front.a);
	}
		ENDCG
	}
	}
			FallBack "Mobile/Diffuse"
}