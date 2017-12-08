/////////////////////////////////////////////////////////////////////////////////////////////
// Copyright 2017 Intel Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
/////////////////////////////////////////////////////////////////////////////////////////////

#include "CPUT.h"
#include "CPUTLight.h"

// Read light properties from .set file
//-----------------------------------------------------------------------------
CPUTResult CPUTLight::LoadLight(CPUTConfigBlock *pBlock, int *pParentID)
{
    ASSERT( (NULL!=pBlock), _L("Invalid NULL parameter.") );

    CPUTResult result = CPUT_SUCCESS;

    // set the null/group node name
    mName = pBlock->GetValueByName(_L("name"))->ValueAsString();

    // get the parent ID
    *pParentID = pBlock->GetValueByName(_L("parent"))->ValueAsInt();

    LoadParentMatrixFromParameterBlock( pBlock );

    cString lightType = pBlock->GetValueByName(_L("lighttype"))->ValueAsString();
    if(lightType.compare(_L("spot")) == 0)
    {
        mLightParams.nLightType = CPUT_LIGHT_SPOT;
    }
    else if(lightType.compare(_L("directional")) == 0)
    {
        mLightParams.nLightType = CPUT_LIGHT_DIRECTIONAL;
    }
    else if(lightType.compare(_L("point")) == 0)
    {
        mLightParams.nLightType = CPUT_LIGHT_POINT;
    }
    else
    {
        // ASSERT(0,_L(""));
        // TODO: why doesn't assert work here?
    }
	lightType.clear();
    pBlock->GetValueByName(_L("Color"))->ValueAsFloatArray(mLightParams.pColor, 3);
    mLightParams.fIntensity    = pBlock->GetValueByName(_L("Intensity"))->ValueAsFloat();
    mLightParams.fInnerAngle      = pBlock->GetValueByName(_L("InnerAngle"))->ValueAsFloat();
    mLightParams.fOuterAngle    = pBlock->GetValueByName(_L("ConeAngle"))->ValueAsFloat();
    mLightParams.fDecayStart   = pBlock->GetValueByName(_L("DecayStart"))->ValueAsFloat();
    mLightParams.bEnableFarAttenuation = pBlock->GetValueByName(_L("EnableNearAttenuation"))->ValueAsBool();
    mLightParams.bEnableFarAttenuation = pBlock->GetValueByName(_L("EnableFarAttenuation"))->ValueAsBool();
    mLightParams.fNearAttenuationStart = pBlock->GetValueByName(_L("NearAttenuationStart"))->ValueAsFloat();
    mLightParams.fNearAttenuationEnd   = pBlock->GetValueByName(_L("NearAttenuationEnd"))->ValueAsFloat();
    mLightParams.fFarAttenuationStart  = pBlock->GetValueByName(_L("FarAttenuationStart"))->ValueAsFloat();
    mLightParams.fFarAttenuationEnd    = pBlock->GetValueByName(_L("FarAttenuationEnd"))->ValueAsFloat();
	mLightParams.bCastShadows = pBlock->GetValueByName(_L("CastShadows"))->ValueAsBool();
    return result;
}