Shader "Unlit/Edge" {
	Properties{
		_MainTex("_MainTex", 2D) = "white" {}
		_Edge("Edge",Range(0,0.5)) = 0
		_Color("Color",color) = (1,1,1,1)
		_EdgeColor("EdgeColor",color) = (1,1,1,1)
	}
		SubShader{
		Tags{ "Queue" = "Transparent"   "RenderType" = "Transparent" }
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		Pass{
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#include "UnityCG.cginc"

		sampler2D _MainTex;
		float4 _MainTex_ST;
		float _Edge;
		fixed4 _Color;
		fixed4 _EdgeColor;

	struct appdata {
		float4 vertex   : POSITION;
		float2 texcoord : TEXCOORD0;
	};

	struct v2f {
		float4 vertex: POSITION;
		float2 texcoord: TEXCOORD0;
	};

	v2f vert(appdata v) {
		v2f o;
		o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
		o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);

		return o;
	}

	fixed4 frag(v2f i) : COLOR{
		fixed4 outColor = tex2D(_MainTex, i.texcoord)*_Color;
		//对八个方向进行采样
		//性能不行的话可以只对四个方向采样
		fixed4 out1 = tex2D(_MainTex, i.texcoord + float2(_Edge,0));//右
		fixed4 out2 = tex2D(_MainTex, i.texcoord + float2(0, _Edge));//上
		fixed4 out3 = tex2D(_MainTex, i.texcoord + float2(0, -_Edge));//下
		fixed4 out4 = tex2D(_MainTex, i.texcoord + float2(-_Edge, 0)); //左
		fixed4 out5 = tex2D(_MainTex, i.texcoord + float2(_Edge / 1.414, _Edge / 1.414));//右上
		fixed4 out6 = tex2D(_MainTex, i.texcoord + float2(_Edge / 1.414,-_Edge / 1.414));//右下
		fixed4 out7 = tex2D(_MainTex, i.texcoord + float2(-_Edge / 1.414, _Edge / 1.414));//左上
		fixed4 out8 = tex2D(_MainTex, i.texcoord + float2(-_Edge / 1.414, -_Edge / 1.414));//左下

		fixed4 o = fixed4(1,1,1,1) - outColor;
		fixed4 edge = o * (out1 + out2 + out3 + out4 + out5 + out6 + out7 + out8);
		edge *= _EdgeColor;

		//非插值方法
		//edge.a += outColor.a;
		//edge.rgb +=  outColor.rgb;
		//return edge;

		//插值的方法
		return lerp(outColor, edge, edge.a);
	}
		ENDCG
	}
	}
}