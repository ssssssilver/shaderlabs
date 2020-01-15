Shader "Unlit/Grass"
{
	Properties{
		_MainTex("Grass Texture", 2D) = "white" {}
		_Color("Color",color)=(1,1,1,1)
		_Speed("Time Scale", range(0,1)) = 0.1//草动的幅度
		_Rate("Rate",range(0,1))=0.5
	}
		SubShader{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		Pass{
		ZWrite OFF
		Cull Back
		CGPROGRAM

#pragma vertex vert
#pragma fragment frag

#include "UnityCG.cginc"

		sampler2D _MainTex;
		half _Speed;
		half _Rate;
		fixed4 _Color;
		struct a2v {
			float4 vertex : POSITION;
			float2 texcoord : TEXCOORD0;
		};

	struct v2f {
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
		float2 uv2 : TEXCOORD1;
	};

		v2f vert(a2v v) {
			v2f o;
			float4 vertexOffset = float4(0,0,0,0);
			//让顶点的y轴进行偏移 sin曲线能让顶点在固定范围内来回移动
			//与uv的y相乘是因为uv是从0到1变化的 控制摇摆频率
			vertexOffset.y = sin( _Time.y*3.14)*clamp(v.texcoord.y- _Rate,0,1) * _Speed;
			o.pos = mul(UNITY_MATRIX_MVP, v.vertex + vertexOffset);
			o.uv = v.texcoord.xy;
			return o;
		}

		fixed4 frag(v2f i) : SV_Target{
			return _Color;
		}
		ENDCG
	}


	}
		FallBack "Mobile/Diffuse"
}