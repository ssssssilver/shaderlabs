Shader "Unlit/line"
    {
    Properties
    {
		_LineColor("LineColor", Color) = (1,1,1,1)
		_GridColor("GridColor", Color) = (1,1,1,0)
		_LineWidth("LineWidth", float) = 0.2
	}
		SubShader
		{
			Tags{ "Queue" = "Transparent" }
			LOD 100
			Blend SrcAlpha OneMinusSrcAlpha
			zwrite off
			Cull off
			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"

			 sampler2D _MainTex;
			 float4 _LineColor;
			 float4 _GridColor;
			 float _LineWidth;

				struct appdata
				{
					float4 vertex : POSITION;
					float4 texcoord : TEXCOORD0;
				};
     
				struct v2f
				{
					float4 pos : SV_POSITION;
					float4 texcoord : TEXCOORD0;
				};
     
				v2f vert (appdata v)
				{
					v2f o;
					o.pos = mul( UNITY_MATRIX_MVP, v.vertex);
					o.texcoord = v.texcoord;
					return o;
				}
     
				fixed4 frag(v2f i) : SV_Target
				{
					fixed4 col;
					float startx = step(_LineWidth, i.texcoord.x);
					float endx = step(i.texcoord.x, 1.0 - _LineWidth);
					float starty = step(_LineWidth, i.texcoord.y);
					float endy = step(i.texcoord.y, 1.0 - _LineWidth);
					//让面的a通道设置透明 可以用插值做出线框效果
					col = lerp(_LineColor, _GridColor, startx*endx*starty*endy);
				return col;
				}
			ENDCG
		}
		}
    }


