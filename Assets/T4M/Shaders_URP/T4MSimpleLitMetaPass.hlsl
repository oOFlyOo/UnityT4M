#ifndef T4M_TEMPLATE_SIMPLE_LIT_META_PASS_INCLUDED
	#define T4M_TEMPLATE_SIMPLE_LIT_META_PASS_INCLUDED

	struct Attributes
	{
		float4 positionOS: POSITION;
		float2 uv0: TEXCOORD0;
	};

	T4M_Meta_Varyings UniversalVertexMeta(Attributes input)
	{
		T4M_Meta_Varyings output;
		output.positionCS = TransformWorldToHClip(input.positionOS);
		// output.uv = TRANSFORM_TEX(input.uv0, _BaseMap);
        InitializeOutputUV(input.uv0, output);
		return output;
	}

	half4 UniversalFragmentMetaSimple(T4M_Meta_Varyings input): SV_Target
	{
		// float2 uv = input.uv;
		// return half4(SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv).rgb, 1);

        half4 texColor = surf(input);
        return half4(texColor.rgb, 1);
	}

#endif
