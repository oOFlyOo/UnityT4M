#ifndef T4M_TEMPLATE_SIMPLE_LIT_PASS_INCLUDED
	#define T4M_TEMPLATE_SIMPLE_LIT_PASS_INCLUDED

	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

	struct Attributes
	{
		float4 positionOS: POSITION;
		float3 normalOS: NORMAL;
		float4 tangentOS: TANGENT;
		float2 texcoord: TEXCOORD0;
		float2 lightmapUV: TEXCOORD1;
		UNITY_VERTEX_INPUT_INSTANCE_ID
	};

	void InitializeInputData(T4M_Varyings input, out InputData inputData)
	{
		inputData.positionWS = input.posWS;

		half3 viewDirWS = input.viewDir;
		inputData.normalWS = input.normal;

		inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
		viewDirWS = SafeNormalize(viewDirWS);

		inputData.viewDirectionWS = viewDirWS;

		#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
			inputData.shadowCoord = input.shadowCoord;
		#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
			inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
		#else
			inputData.shadowCoord = float4(0, 0, 0, 0);
		#endif

		inputData.fogCoord = input.fogFactorAndVertexLight.x;
		inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
		inputData.bakedGI = SAMPLE_GI(input.lightmapUV, input.vertexSH, inputData.normalWS);
	}

	///////////////////////////////////////////////////////////////////////////////
	//                  Vertex and Fragment functions                            //
	///////////////////////////////////////////////////////////////////////////////

	// Used in Standard (Simple Lighting) shader
	T4M_Varyings LitPassVertexSimple(Attributes input)
	{
		T4M_Varyings output = (T4M_Varyings)0;

		UNITY_SETUP_INSTANCE_ID(input);
		UNITY_TRANSFER_INSTANCE_ID(input, output);
		UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

		VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
		VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
		half3 viewDirWS = GetCameraPositionWS() - vertexInput.positionWS;
		half3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);
		half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);

		// output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
		InitializeOutputUV(input.texcoord, output);
		output.posWS.xyz = vertexInput.positionWS;
		output.positionCS = vertexInput.positionCS;

		output.normal = NormalizeNormalPerVertex(normalInput.normalWS);
		output.viewDir = viewDirWS;

		OUTPUT_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV);
		OUTPUT_SH(output.normal.xyz, output.vertexSH);

		output.fogFactorAndVertexLight = half4(fogFactor, vertexLight);

		#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
			output.shadowCoord = GetShadowCoord(vertexInput);
		#endif

		return output;
	}

	// Used for StandardSimpleLighting shader
	half4 LitPassFragmentSimple(T4M_Varyings input): SV_Target
	{
		UNITY_SETUP_INSTANCE_ID(input);
		UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

		// float2 uv = input.uv;
		// half4 texColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
		half4 texColor = surf(input);
		half3 diffuse = texColor.rgb;

		half alpha = texColor.a;

		half3 emission = 0;
		half4 specular = half4(0.0h, 0.0h, 0.0h, 1.0h);
		half smoothness = specular.a;

		InputData inputData;
		InitializeInputData(input, inputData);

		half4 color = UniversalFragmentBlinnPhong(inputData, diffuse, specular, smoothness, emission, alpha);
		color.rgb = MixFog(color.rgb, inputData.fogCoord);
		return color;
	};

#endif
