/////////////////////////////////////////////////////////////////////////////////////////////
// Copyright 2017 Intel Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");// you may not use this file except in compliance with the License.// You may obtain a copy of the License at//// http://www.apache.org/licenses/LICENSE-2.0//// Unless required by applicable law or agreed to in writing, software// distributed under the License is distributed on an "AS IS" BASIS,// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.// See the License for the specific language governing permissions and// limitations under the License.
/////////////////////////////////////////////////////////////////////////////////////////////

// -------------------------------------
cbuffer cbPerModelValues
{
    row_major float4x4 World : WORLD;
    row_major float4x4 NormalMatrix : WORLD;
    row_major float4x4 WorldViewProjection : WORLDVIEWPROJECTION;
    row_major float4x4 InverseWorld : WORLDINVERSE;
    row_major float4x4 LightWorldViewProjection;
              float4   BoundingBoxCenterWorldSpace  < string UIWidget="None"; >;
              float4   BoundingBoxHalfWorldSpace    < string UIWidget="None"; >;
              float4   BoundingBoxCenterObjectSpace < string UIWidget="None"; >;
              float4   BoundingBoxHalfObjectSpace   < string UIWidget="None"; >;
};

// -------------------------------------
cbuffer cbPerFrameValues
{
    row_major float4x4  View;
    row_major float4x4  InverseView : ViewInverse	< string UIWidget="None"; >;
    row_major float4x4  Projection;
    row_major float4x4  ViewProjection;
              float4    AmbientColor < string UIWidget="None"; > = .20;
              float4    LightColor < string UIWidget="None"; >   = 1.0f;
              float4    LightDirection  : Direction < string UIName = "Light Direction";  string Object = "TargetLight"; string Space = "World"; int Ref_ID=0; > = {0,0,-1, 0};
              float4    EyePosition;
              float4    TotalTimeInSeconds < string UIWidget="None"; >;
			  float4    MultiSampleCount;           // .x == multisample count; .y = 1.0/x
};

struct VS_INPUT
{
    float3 Position : POSITION; // Projected position
    float3 Normal   : NORMAL;
    float3 Tangent  : TANGENT;
    float3 Binormal : BINORMAL;
    float2 UV0      : TEXCOORD0;
    float2 UV1      : TEXCOORD1;
};

// -------------------------------------
struct PS_INPUT
{
    float4 Position : SV_POSITION;
    float3 Normal   : NORMAL;
    float3 Tangent  : TANGENT;
    float3 Binormal : BINORMAL;
    float2 UV0      : TEXCOORD0;
    float2 UV1      : TEXCOORD1;
    float4 LightUV       : TEXCOORD2;
    float3 WorldPosition : TEXCOORD3; // Object space position 
};

// -------------------------------------
#ifdef _CPUT
    SamplerState SAMPLER0 : register( s0 );
    SamplerComparisonState SHADOW_SAMPLER : register( s1);
    Texture2D texture_AO : register( t0 );
    Texture2D texture_DM : register( t1 );
    Texture2D texture_NM : register( t2 );
    Texture2D texture_SM : register( t3 );
    Texture2D texture_ST : register( t4 );
    Texture2D _Shadow : register( t5 );
    Texture2D _InternalShadow : register( t6 );
#else
    texture2D texture_AO < string Name = "texture_AO"; string UIName = "texture_AO"; string ResourceType = "2D";>;
    sampler2D SAMPLER0 = sampler_state{ texture = (texture_AO);};
    texture2D texture_DM < string Name = "texture_DM"; string UIName = "texture_DM"; string ResourceType = "2D";>;
    sampler2D SAMPLER1 = sampler_state{ texture = (texture_DM);};
    texture2D texture_NM < string Name = "texture_NM"; string UIName = "texture_NM"; string ResourceType = "2D";>;
    sampler2D SAMPLER2 = sampler_state{ texture = (texture_NM);};
    texture2D texture_SM < string Name = "texture_SM"; string UIName = "texture_SM"; string ResourceType = "2D";>;
    sampler2D SAMPLER3 = sampler_state{ texture = (texture_SM);};
    texture2D texture_ST < string Name = "texture_ST"; string UIName = "texture_ST"; string ResourceType = "2D";>;
    sampler2D SAMPLER4 = sampler_state{ texture = (texture_ST);};
#endif

// -------------------------------------
float4 DIFFUSE( PS_INPUT input )
{
    return 
#ifdef _CPUT
texture_DM.Sample( SAMPLER0, (((input.UV0)) *(10)) )
#else
tex2D( SAMPLER1, (((input.UV0)) *(10)) )
#endif
;
}

// -------------------------------------
float4 SPECULAR( PS_INPUT input )
{
    return 
#ifdef _CPUT
texture_SM.Sample( SAMPLER0, (((input.UV0)) *(10)) )
#else
tex2D( SAMPLER3, (((input.UV0)) *(10)) )
#endif
;
}

// -------------------------------------
float4 SPECULARITY( PS_INPUT input )
{
    return ((
#ifdef _CPUT
texture_ST.Sample( SAMPLER0, (((input.UV0)) *(10)) )
#else
tex2D( SAMPLER4, (((input.UV0)) *(10)) )
#endif
) *(128)) +(4);
}

// -------------------------------------
float4 NORMAL( PS_INPUT input )
{
    return ((
#ifdef _CPUT
texture_NM.Sample( SAMPLER0, (((input.UV0)) *(10)) )
#else
tex2D( SAMPLER2, (((input.UV0)) *(10)) )
#endif
) *(2)) -(1);
}

// -------------------------------------
float4 AMBIENTOCC( PS_INPUT input )
{
    return 
#ifdef _CPUT
texture_AO.Sample( SAMPLER0, (((input.UV1)) *(1)) ).xxxx
#else
tex2D( SAMPLER0, (((input.UV1)) *(1)) ).xxxx
#endif
;
}

// -------------------------------------
float4 AMBIENT( PS_INPUT input )
{
    return ((DIFFUSE(input)* 5) *(AMBIENTOCC(input))) *(1);
}

// -------------------------------------
float ComputeShadowAmount( PS_INPUT input )
{
#ifdef _CPUT
    float3  lightUV = input.LightUV.xyz / input.LightUV.w;
    lightUV.xy = lightUV.xy * 0.5f + 0.5f; // TODO: Move to matrix?
    lightUV.y  = 1.0f - lightUV.y;
    float  shadowAmount      = _Shadow.SampleCmp( SHADOW_SAMPLER, lightUV, lightUV.z );
    return shadowAmount*0.5f;
#else
    return 0.5f;
#endif
}
// -------------------------------------
float ComputeInternalShadowAmount( PS_INPUT input )
{
#ifdef _CPUT
    float3  lightUV = input.LightUV.xyz / input.LightUV.w;
    lightUV.xy = lightUV.xy * 0.5f + 0.5f; // TODO: Move to matrix?
    lightUV.y  = 1.0f - lightUV.y;
    float  shadowAmount      = _InternalShadow.SampleCmp( SHADOW_SAMPLER, lightUV, lightUV.z );
    return shadowAmount*0.5;
#else
    return 0.5f;
#endif
}

// -------------------------------------
PS_INPUT VSMain( VS_INPUT input )
{
    PS_INPUT output = (PS_INPUT)0;

    output.Position      = mul( float4( input.Position, 1.0f), WorldViewProjection );
    output.WorldPosition = mul( float4( input.Position, 1.0f), World ).xyz;

    // TODO: transform the light into object space instead of the normal into world space
    output.Normal   = mul( input.Normal, (float3x3)World );
    output.Tangent  = mul( input.Tangent, (float3x3)World );
    output.Binormal = mul( input.Binormal, (float3x3)World );
    output.UV0 = input.UV0;
    output.UV1 = input.UV1;
    output.LightUV = mul( float4( input.Position, 1.0f), LightWorldViewProjection );

    return output;
}

// -------------------------------------
float4 PSMain( PS_INPUT input ) : SV_Target
{
    float4 result = float4(0,0,0,1);

    float  shadowAmount = ComputeShadowAmount(input)+ComputeInternalShadowAmount(input);
    float3 normal   = input.Normal;
    float3 tangent  = input.Tangent;
    float3 binormal = input.Binormal;
    float3x3 worldToTangent = float3x3(tangent, binormal, normal);
    normal = normalize( mul( NORMAL(input), worldToTangent ));

    // Ambient-related computation
    float3 ambient = AmbientColor * AMBIENT(input);
    result.xyz +=  ambient;
#ifdef _CPUT
   float3 lightDirection = -LightDirection;
#else
   float3 lightDirection = LightDirection;
#endif

    // Diffuse-related computation
    float  nDotL         = saturate( dot( normal, lightDirection ) );
    float3 diffuse       = LightColor * nDotL * shadowAmount  * DIFFUSE(input);
    result.xyz += diffuse;

    // Specular-related computation
    float3 eyeDirection  = normalize(input.WorldPosition - EyePosition);
    float3 reflection    = normalize(reflect( eyeDirection, normal ));
    float  rDotL         = saturate(dot( reflection, lightDirection ));
    float3 specular      = pow(rDotL,  SPECULARITY(input) );
    specular             = shadowAmount * specular;
    specular            *= SPECULAR(input);
    result.xyz += LightColor * specular;
    return result;
}

// -------------------------------------
technique DefaultTechnique
{
    pass pass1
    {
        VertexShader        = compile vs_3_0 VSMain();
        PixelShader         = compile ps_3_0 PSMain();
        ZWriteEnable        = true;
    }
}

