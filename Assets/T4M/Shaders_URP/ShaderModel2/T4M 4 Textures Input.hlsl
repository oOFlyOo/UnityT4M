#ifndef T4M_SHADERMODEL2_4TEXTURES_SIMPLE_LIT_INPUT_INCLUDED
	#define T4M_SHADERMODEL2_4TEXTURES_SIMPLE_LIT_INPUT_INCLUDED

	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
	#include "../T4MCommon.hlsl"

	CBUFFER_START(UnityPerMaterial)
	float4 _Control_ST;
	float4 _Splat0_ST, _Splat1_ST, _Splat2_ST, _Splat3_ST;

	float4 _Tiling3;
	CBUFFER_END

	T4M_TEXTURE2D_SAMPLER(_Control);
	T4M_TEXTURE2D_SAMPLER(_Splat0);
	T4M_TEXTURE2D_SAMPLER(_Splat1);
	T4M_TEXTURE2D_SAMPLER(_Splat2);
	T4M_TEXTURE2D_SAMPLER(_Splat3);

	struct T4M_Varyings
	{
		DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 1);

		float3 posWS: TEXCOORD2;    // xyz: posWS

		float3  normal: TEXCOORD3;
		float3 viewDir: TEXCOORD4;

		half4 fogFactorAndVertexLight: TEXCOORD5; // x: fogFactor, yzw: vertex light

		#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
			float4 shadowCoord: TEXCOORD0;
		#endif

		float4 positionCS: SV_POSITION;

		T4M_DECLARE_UV(uv_Control, 6);
		T4M_DECLARE_UV(uv_Splat0, 7);
		T4M_DECLARE_UV(uv_Splat1, 8);
		T4M_DECLARE_UV(uv_Splat2, 9);
		T4M_DECLARE_UV(uv_Splat3, 10);

		UNITY_VERTEX_INPUT_INSTANCE_ID
		UNITY_VERTEX_OUTPUT_STEREO
	};


	void InitializeOutputUV(float2 texcoord, inout T4M_Varyings output)
	{
		T4M_TRANSFORM_TEX(texcoord, output, _Control);
		T4M_TRANSFORM_TEX(texcoord, output, _Splat0);
		T4M_TRANSFORM_TEX(texcoord, output, _Splat1);
		T4M_TRANSFORM_TEX(texcoord, output, _Splat2);
		T4M_TRANSFORM_TEX(texcoord, output, _Splat3);
	}

	half4 surf(T4M_Varyings IN)
	{
		fixed4 splat_control = T4M_SAMPLE_TEXTURE2D(_Control, IN.uv_Control).rgba;

		fixed3 lay1 = T4M_SAMPLE_TEXTURE2D(_Splat0, IN.uv_Splat0);
		fixed3 lay2 = T4M_SAMPLE_TEXTURE2D(_Splat1, IN.uv_Splat1);
		fixed3 lay3 = T4M_SAMPLE_TEXTURE2D(_Splat2, IN.uv_Splat2);
		fixed3 lay4 = T4M_SAMPLE_TEXTURE2D(_Splat3, IN.uv_Control * _Tiling3.xy);

		half3 rgb = (lay1 * splat_control.r + lay2 * splat_control.g + lay3 * splat_control.b + lay4 * splat_control.a);

		return half4(rgb, 0);
	}

#endif
