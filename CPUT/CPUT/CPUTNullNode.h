/////////////////////////////////////////////////////////////////////////////////////////////
// Copyright 2017 Intel Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
/////////////////////////////////////////////////////////////////////////////////////////////
#ifndef __CPUTNULLNODE_H__
#define __CPUTNULLNODE_H__

#include "CPUTRenderNode.h"

class CPUTConfigBlock;

class CPUTNullNode:public CPUTRenderNode
{
public:
    CPUTNullNode(){}
    ~CPUTNullNode(){}
    CPUT_NODE_TYPE GetNodeType() { return CPUT_NODE_NULL;};

    CPUTResult LoadNullNode(CPUTConfigBlock *pBlock, int *pParentID);


};

#endif // #ifndef __CPUTNULLNODE_H__