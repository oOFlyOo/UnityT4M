#ifndef T4M_SIMPLE_LIT_META_PASS_INCLUDED
#define T4M_SIMPLE_LIT_META_PASS_INCLUDED

struct Attributes
{
    float4 positionOS   : POSITION;
    float2 uv0          : TEXCOORD0;
};

struct Varyings
{
    float4 positionCS   : SV_POSITION;
    float2 uv           : TEXCOORD0;
};

Varyings UniversalVertexMeta(Attributes input)
{
    Varyings output;
    output.positionCS = TransformWorldToHClip(input.positionOS);
    output.uv = TRANSFORM_TEX(input.uv0, _BaseMap);
    return output;
}

half4 UniversalFragmentMetaSimple(Varyings input) : SV_Target
{
    float2 uv = input.uv;

    return half4(SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv).rgb, 1);
}

#endif
