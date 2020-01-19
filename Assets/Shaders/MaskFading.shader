Shader "Unlit/MaskFading"
{
	Properties{ 
		_MaskTex("_MaskTex", 2D) = "white" {}
		_Progress("Progress", Range(0,1)) = 0
		_Color("Color",color) = (0,0,0,0)
		_blurOffset("Blur",Range(0,0.03)) = 0.0075
		_RotateSpeed("RotateSpeed",Range(0,10)) = 5 }
	SubShader
	{ 
		Tags{ "RenderType" = "Transparent" "Queue" = "Transparent" }		
		Blend SrcAlpha OneMinusSrcAlpha		
		//Cull Off 
		ZWrite Off 
		ZTest Always 

		Pass{ 
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
		};
		sampler2D _MaskTex;		
		float _Progress;
		float4 _MaskTex_ST;		
		fixed4 _Color;		
		fixed _blurOffset;		
		fixed _RotateSpeed; 		
		v2f vert(appdata v)		
		{			
			v2f o;			
			o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);			
			

			//手动控制缩放			
			_Progress =pow(1000,_Progress);			

			//offset偏移			 
			v.uv -= fixed2(0.5, 0.5);
			//旋转公式	
			v.uv = fixed2(v.uv.x * cos(_RotateSpeed * _Time.y) -v.uv.y * sin(_RotateSpeed * _Time.y),v.uv.x * sin(_RotateSpeed * _Time.y) +v.uv.y * cos(_RotateSpeed * _Time.y))*_Progress;
			
			//复原offset			
			v.uv += fixed2(0.5, 0.5);
			o.uv = TRANSFORM_TEX(v.uv, _MaskTex);
			return o;		
		}		
	
		fixed4 frag(v2f i) : SV_Target		
		{				
		
			fixed4 maskcol = tex2D(_MaskTex, i.uv);  			
			//高斯模糊			
			//leftup			
			fixed4 maskcol1 = tex2D(_MaskTex, i.uv +fixed2(-_blurOffset, _blurOffset));
			//leftdown			
			fixed4 maskcol2 = tex2D(_MaskTex, i.uv + fixed2(-_blurOffset, -_blurOffset));
			//rightup			
			fixed4 maskcol3 = tex2D(_MaskTex, i.uv + fixed2(_blurOffset, _blurOffset));
			//rightdown			
			fixed4 maskcol4 = tex2D(_MaskTex, i.uv + fixed2(-_blurOffset, -_blurOffset));
			
			//up			
			fixed4 maskcol5 = tex2D(_MaskTex, i.uv + fixed2(0, _blurOffset));
			//down			
			fixed4 maskcol6 = tex2D(_MaskTex, i.uv + fixed2(0,-_blurOffset));
			//right			
			fixed4 maskcol7 = tex2D(_MaskTex, i.uv + fixed2(_blurOffset, 0));
			//left			
			fixed4 maskcol8 = tex2D(_MaskTex, i.uv + fixed2(-_blurOffset, 0));
			fixed4 mix = (maskcol + maskcol1 + maskcol2 + maskcol3 + maskcol4+maskcol5+ maskcol6+ maskcol7+ maskcol8)/9;
			mix = lerp(maskcol, mix, 0.5);			
		
			fixed a = 1 - mix.a;			
			return fixed4(_Color.rgb, a);
		}		
			ENDCG
		}
	}
}
