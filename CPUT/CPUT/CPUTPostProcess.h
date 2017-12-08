/////////////////////////////////////////////////////////////////////////////////////////////
// Copyright 2017 Intel Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
/////////////////////////////////////////////////////////////////////////////////////////////
#ifndef _CPUTPOSTPROCESS_H
#define _CPUTPOSTPROCESS_H

class CPUTRenderTargetColor;
class CPUTMaterial;
class CPUTRenderParameters;
class CPUTSprite;

class CPUTPostProcess
{
protected:
    CPUTRenderTargetColor *mpRTSourceRenderTarget;
    CPUTRenderTargetColor *mpRTDownSample4x4;
    CPUTRenderTargetColor *mpRTDownSample4x4PingPong;
    CPUTRenderTargetColor *mpRT64x64;
    CPUTRenderTargetColor *mpRT4x4;
    CPUTRenderTargetColor *mpRT1x1;

    CPUTMaterial *mpMaterialDownSampleBackBuffer4x4;
    CPUTMaterial *mpMaterialDownSample4x4;
    CPUTMaterial *mpMaterialDownSample4x4Alpha;
    CPUTMaterial *mpMaterialDownSampleLogLum;
    CPUTMaterial *mpMaterialBlurHorizontal;
    CPUTMaterial *mpMaterialBlurVertical;
    CPUTMaterial *mpMaterialComposite;

    CPUTSprite   *mpFullScreenSprite;

public:
    CPUTPostProcess() :
        mpRTSourceRenderTarget(NULL),
        mpRTDownSample4x4(NULL),
        mpRTDownSample4x4PingPong(NULL),
        mpRT64x64(NULL),
        mpRT4x4(NULL),
        mpRT1x1(NULL),
        mpMaterialDownSampleBackBuffer4x4(NULL),
        mpMaterialDownSample4x4(NULL),
        mpMaterialDownSample4x4Alpha(NULL),
        mpMaterialDownSampleLogLum(NULL),
        mpMaterialBlurHorizontal(NULL),
        mpMaterialBlurVertical(NULL),
        mpMaterialComposite(NULL),
        mpFullScreenSprite(NULL)
    {}
    ~CPUTPostProcess();

    void CreatePostProcess( CPUTRenderTargetColor *pSourceRenderTarget );
    void RecreatePostProcess();
    void PerformPostProcess(CPUTRenderParameters &renderParams);
};

#endif // _CPUTPOSTPROCESS_H