Shader "Custom/LocalCubemapReflectionSub" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
	    _Cube("Local Cuebmaps", Cube) = "balck"{}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_reflection ("reflection", Range(0, 3)) = 0

	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
        AlphaTest Off
		CGPROGRAM
		#pragma surface surf Standard noforwardadd approxview noambient nodirlightmap fullforwardshadows 
		#pragma target 3.0
		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
            float4 screenPos;
            float3 worldRefl;
            float3 worldPos;
		};
		uniform sampler2D _ReflectionTex;
		uniform samplerCUBE _Cube;
        uniform half3 _boxMin;
		uniform half3 _boxMax;
		uniform half3 _cubemapPos;
		uniform fixed _reflection;
		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
        half3 LocalCorrect(half3 origVec, half3 bboxMin, half3 bboxMax, half3 vertexPos, half3 cubemapPos);
		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) ;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;

			fixed4 rtRefl = tex2D(_ReflectionTex, (IN.screenPos.xy / IN.screenPos.w));
            half3 localCubeRefl = LocalCorrect(IN.worldRefl, _boxMin, _boxMax, IN.worldPos, _cubemapPos);
		    fixed4 cube = texCUBE(_Cube, localCubeRefl);
			rtRefl.rgb = (1 - rtRefl.a) * cube.rgb  + rtRefl.a * rtRefl.rgb;
			
			o.Albedo.rgb = c * _Color + _reflection * rtRefl.rgb;
		}

        half3 LocalCorrect(half3 origVec, half3 bboxMin, half3 bboxMax, half3 vertexPos, half3 cubemapPos)
		{
			// Find the ray intersection with box plane
			half3 invOrigVec = half3(1.0,1.0,1.0)/origVec;
			half3 intersecAtMaxPlane = (bboxMax - vertexPos) * invOrigVec;
			half3 intersecAtMinPlane = (bboxMin - vertexPos) * invOrigVec;
			// Get the largest intersection values
			// (we are not intersted in negative values)
			half3 largestIntersec = max(intersecAtMaxPlane, intersecAtMinPlane);
			// Get the closest of all solutions
			half Distance = min(min(largestIntersec.x, largestIntersec.y),
									largestIntersec.z);
			// Get the intersection position
			half3 IntersectPositionWS = vertexPos + origVec * Distance;
			// Get corrected vector
			half3 localCorrectedVec = IntersectPositionWS - cubemapPos;
			return localCorrectedVec;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
