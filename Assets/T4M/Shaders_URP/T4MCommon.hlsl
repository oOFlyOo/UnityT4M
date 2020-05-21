#ifndef T4M_TEMPLATE_COMMON_INCLUDED
	#define T4M_TEMPLATE_COMMON_INCLUDED

	#define T4M_DECLARE_UV(name, index)  float2 name: TEXCOORD##index
	#define T4M_TRANSFORM_TEX(input, output, name)  output.uv##name = TRANSFORM_TEX(input, name)
	#define T4M_SAMPLE_TEXTURE2D(input, uv)  SAMPLE_TEXTURE2D(input, sampler##input, uv)
	#define T4M_TEXTURE2D_SAMPLER(name) TEXTURE2D(name); SAMPLER(sampler##name);

	#define fixed4 half4
	#define fixed3 half3

#endif
