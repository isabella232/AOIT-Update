/////////////////////////////////////////////////////////////////////////////////////////////
// Copyright 2017 Intel Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
/////////////////////////////////////////////////////////////////////////////////////////////

#ifndef H_AIOT_RESOLVE
#define H_AIOT_RESOLVE


#include "AOIT.hlsl"

float4 AOITSPResolvePS(float4 pos: SV_POSITION, float2 tex : TEX_COORD0) : SV_Target
{
	float4 outColor = float4(0, 0, 0, 1);
    uint2 pixelAddr = uint2(pos.xy);

    // display debug colour
    //return float4( 0, 1, 0, 1.0 );

	// Load control surface
	AOITCtrlSurface ctrlSurface;
	AOITLoadControlSurfaceSRV(pixelAddr, ctrlSurface);

	// Any transparent fragment contributing to this pixel?
	if (!ctrlSurface.clear) 
	{
		// Load all nodes for this pixel    
		ATSPNode nodeArray[AOIT_NODE_COUNT];
		AOITSPLoadDataSRV(pixelAddr, nodeArray);

		// Accumulate final transparent colors
		float  trans = 1;
		float3 color = 0;       
		[unroll]for(uint i = 0; i < AOIT_NODE_COUNT; i++) {
#ifdef dohdr
			color += trans * FromRGBE(UnpackRGBA(nodeArray[i].color));
#else
			color += trans * UnpackRGB(nodeArray[i].color);
#endif
			trans  = nodeArray[i].trans / 255;
		}
		outColor = float4(color, nodeArray[AOIT_NODE_COUNT - 1].trans / 255);
	}

    // blend accumualted transparent color with opaque background color
    return outColor;
}

[earlydepthstencil]
void AOITSPClearPS( float4 pos: SV_POSITION, float2 tex : TEX_COORD0 )
{
    uint2 pixelAddr = uint2(pos.xy);

	uint addr = AOITAddrGenUAV(pixelAddr);

	uint data = 0x1; // is clear
	gAOITSPClearMaskUAV[pixelAddr] = data;

}

#endif // H_AIOT_RESOLVE