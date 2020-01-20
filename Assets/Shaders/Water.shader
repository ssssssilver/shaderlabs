Shader "Unlit/Water" {
	Properties{
		_MainTex("MainTex", 2D) = "white" {}
		_Color("Main Color", Color) = (1, 1, 1, 1)
		_WaveMap("Wave Map", 2D) = "bump" {}
		_Cubemap("Sky", Cube) = "_Skybox" {}
		_WaveXSpeed("WaveXSpeed", Range(-0.1, 0.1)) = 0.01
		_WaveYSpeed("WaveYSpeed", Range(-0.1, 0.1)) = 0.01
		_Distortion("Distortion", Range(0, 100)) = 10
	}
		SubShader{
		Tags{ "Queue" = "Transparent" "RenderType" = "Opaque" }
		//截取屏幕采样用作下一个pass的折射贴图
		GrabPass{ "_RefractionTex" }

		Pass{
		Tags{ "LightMode" = "ForwardBase" }

		CGPROGRAM

		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma multi_compile_fwdbase

		#pragma vertex vert
		#pragma fragment frag

		fixed4 _Color;
		sampler2D _MainTex;
		//声名采样图后 才能进行TRANSFORM_TEX操作
		float4 _MainTex_ST;
		//由噪声纹理生成的法线纹理
		sampler2D _WaveMap;
		float4 _WaveMap_ST;
		//模拟反射的立方体纹理
		samplerCUBE _Cubemap;
		//xy轴的平稳速度
		fixed _WaveXSpeed;
		fixed _WaveYSpeed;
		//折射图像的扭曲程度
		float _Distortion;
		//对应GabPass定义的纹理变量
		//_TexelSize后缀可以得到纹理的纹素大小 256*256的纹理图片  纹素为(1/256,1/256)
		sampler2D _RefractionTex;
		float4 _RefractionTex_TexelSize;

	struct a2v {
		//a to vert的变量声明都是模型坐标的
		float4 vertex : POSITION;
		float3 normal : NORMAL;
		float4 tangent : TANGENT;
		float4 texcoord : TEXCOORD0;
	};

	struct v2f {
		float4 pos : SV_POSITION;
		float4 scrPos : TEXCOORD0;
		float4 uv : TEXCOORD1;
		float4 TtoW0 : TEXCOORD2;
		float4 TtoW1 : TEXCOORD3;
		float4 TtoW2 : TEXCOORD4;
	};

	v2f vert(a2v v) {
		v2f o;
		o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
		//输入参数pos是经过MVP矩阵变换后在裁剪空间中的顶点坐标
		//获取pos点在屏幕图像的纹理坐标
		o.scrPos = ComputeGrabScreenPos(o.pos);
		//取maintex的uv为xy 对应前面声名的_MainTex_ST
		//取wavemap的uv为zw 对应前面声名的_WaveMap_ST
		o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
		o.uv.zw = TRANSFORM_TEX(v.texcoord, _WaveMap);
		//全部转成世界坐标
		float3 worldPos = mul(_Object2World, v.vertex).xyz;
		//把法线从模型坐标转换到世界坐标
		fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
		//把切线从模型坐标转换到世界坐标
		fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
		//获取副法线
		fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;
		//创建顶点从切线空间到世界空间的矩阵变换 xyz轴分别对应切线 副切线 法线的方向
		o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
		o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
		o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

		return o;
	}

	fixed4 frag(v2f i) : SV_Target{
		float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
		fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
		float2 speed = _Time.y * float2(_WaveXSpeed, _WaveYSpeed);

		//对法线纹理进行两次采样
		//模拟两层交叉的水面波动效果
		//只用一次采样 水波会往一个方向扩散
		fixed3 bump0 = tex2D(_WaveMap, i.uv.zw + speed);
		fixed3 bump1 = UnpackNormal(tex2D(_WaveMap, i.uv.zw + speed)).rgb;
		fixed3 bump2 = UnpackNormal(tex2D(_WaveMap, i.uv.zw - speed)).rgb;
		//bump1 = fixed3(0,0,0);
		fixed3 bump = normalize(bump1 + bump2);

		float2 offset = bump.xy * _Distortion* _RefractionTex_TexelSize.xy;
		i.scrPos.xy = offset * i.scrPos.z + i.scrPos.xy;
		fixed3 refrCol = tex2D(_RefractionTex, i.scrPos.xy / i.scrPos.w).rgb;

		//将法线方向从切线空间转换到世界空间
		//使用变换矩阵(TtoW0,TtoW1,TtoW2)的每一行分别与法线方向点乘
		bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
		fixed4 texColor = tex2D(_MainTex, i.uv.xy + speed);
		//获取反射方向
		fixed3 reflDir = reflect(-viewDir, bump);
		//对立体材质进行采样 并与主颜色相乘
		fixed3 reflCol = texCUBE(_Cubemap, reflDir).rgb * texColor.rgb * _Color.rgb;
		//使用菲涅尔系数来混合折射与反射的颜色
		fixed fresnel = pow(1 - saturate(dot(viewDir, bump)), 4);
		//fixed3 finalColor = lerp(refrCol, reflCol, fresnel);
		fixed3 finalColor = reflCol * fresnel + refrCol * (1 - fresnel);

		return fixed4(finalColor, 1);
	}

		ENDCG
	}
	}
FallBack Off
}
