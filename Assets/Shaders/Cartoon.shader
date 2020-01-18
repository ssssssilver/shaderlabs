Shader "Unlit/Cartoon"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
	//渐变纹理
		_Ramp("RampTexture",2D) = "white"{}
		_Color("Color",Color) = (1,1,1,1)
		_Outline("Outline", Range(0,0.2)) = 0.1
		_OutlineColor("OutlineColor",Color) = (1,1,1,1)
		_Specular("Specular",Color) = (1,1,1,1)
		//高光阀值
		_SpecularScale("Scale",Range(0,0.1)) = 0.1
	}
		SubShader
	{

		LOD 100
		//创建一个通道 只渲染背面 作为外边框效果 第二个通道叠在此通道上面
		Pass
		{
			Tags{ "RenderType" = "Opaque" }
		Cull Front
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#include "UnityCG.cginc"

		float _Outline;
		float4 _OutlineColor;
		struct a2v
		{
			float4 vertex:POSITION;
			float3 normal:NORMAL;
		};

		struct v2f
		{
			float4 pos :POSITION;
		};

		v2f vert(a2v a)
		{
			v2f o;
			float4 viewPos = mul(UNITY_MATRIX_MV, a.vertex);
			float3 viewNormal = mul((float3x3)UNITY_MATRIX_IT_MV, a.normal);
			//统一z轴
			viewNormal.z = -0.5;
			//向外偏移
			viewPos = viewPos + float4(normalize(viewNormal), 0)*_Outline;
			o.pos = mul(UNITY_MATRIX_P, viewPos);
			return o;
		}

		float4 frag(v2f v) :SV_Target
		{
			return _OutlineColor.rgba;
		}
		ENDCG
	}

	Pass
	{

		Tags{ "LightMode" = "ForwardBase" "Queue" = "Geometry" }

		Cull Back

			CGPROGRAM

		#pragma vertex vert
		#pragma fragment frag

		#pragma multi_compile_fwdbase

		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#include "AutoLight.cginc"
		#include "UnityShaderVariables.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 tangent : TANGENT;
				float3 normal : NORMAL;
			};


			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 pos:POSITION;
				float3 worldNormal:TEXCOORD1;
				float3 worldPos:TEXCOORD2;
				SHADOW_COORDS(3)
			};

			sampler2D _MainTex;
			sampler2D _Ramp;
			float4 _MainTex_ST;
			fixed4 _Color;
			fixed4 _Specular;
			fixed _SpecularScale;

			v2f vert(appdata v)
			{
				v2f o;
				//o.pos = UnityObjectToClipPos(v.vertex);
				o.pos=mul(UNITY_MATRIX_MVP,v.vertex);

				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				//矩阵转置 将本地的法线坐标转换成世界法线
				//可用o.worldNormal=UnityObjectToWorldNormal(v.normal);
				o.worldNormal = mul(v.normal,(float3x3)_World2Object);
				o.worldPos = mul(_Object2World,v.vertex).xyz;
				//计算阴影
				TRANSFER_SHADOW(o);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				//半角向量=光线方向+视线方向
				fixed3 halfDir = normalize(worldLightDir + worldViewDir);


				fixed4 col = tex2D(_MainTex, i.uv);
				//反射率
				fixed3 albedo = col.rgb*_Color.rgb;
				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				//在unity中，主要是通过一个shadowCaster的shader来实现对阴影的计算，
				//对于物体是否投射阴影可以在其自身的组件上设置。
				//而unity将阴影和衰减的计算合并在一起，主要通过三个基本的内部操作来实现
				//1.在a2v的结构体中设置SHADOW_COORDS(n)，
				//2.在vert shader中进行TRANSFER_SHADOW(o)，
				//3.最后在frag shader中进行 UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos)，
				//此时得到的atten就是综合了衰减和阴影的结果，
				//可以用其来作为衰减和阴影的因子与最终的光照颜色相乘
				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

				//点乘 返回夹角
				fixed diff = dot(worldNormal, worldLightDir);
				diff = (diff * 0.5 + 0.5) * atten;
				fixed3 diffuse = _LightColor0.rgb * albedo * tex2D(_Ramp, float2(diff, diff)).rgb;

				fixed spec = dot(worldNormal, halfDir);
				//求高光部分的偏导值
				fixed w = fwidth(spec) ;
				//高光计算
				fixed3 specular = _Specular.rgb * lerp(0, 1, smoothstep(-w, w, spec + _SpecularScale-1)) * step(0.0001, _SpecularScale);
				return fixed4(ambient + diffuse + specular,1.0);
			}
			ENDCG
		}
	}
		FallBack "Diffuse"
}