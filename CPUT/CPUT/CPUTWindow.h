/////////////////////////////////////////////////////////////////////////////////////////////
// Copyright 2017 Intel Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
/////////////////////////////////////////////////////////////////////////////////////////////

#ifndef __CPUTWINDOW_H__
#define __CPUTWINDOW_H__

// abstract base window class
//-----------------------------------------------------------------------------
class CPUTWindow
{
public:
    // construction
	CPUTWindow(){};
	~CPUTWindow(){};

    // screen/window dimensions
    virtual void GetClientDimensions( int *pWidth, int *pHeight) = 0;
    virtual void GetClientDimensions( int *pX, int *pY, int *pWidth, int *pHeight) = 0;
	virtual void SetClientDimensions( int Width, int Height){};
};

#endif