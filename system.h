//
//  Created by Matt Hartley on 23/02/2025.
//  Copyright 2025 GiantJelly. All rights reserved.
//

#ifndef __SYSTEM_H__
#define __SYSTEM_H__

#include <core/core.h>
#include "bitmap.h"

typedef struct {
	b32 running;
	allocator_t assertMemory;

	bitmap_t* testBitmap;

	u8 objc_state[128];
} sys_t;

void S_Init();
void S_Update();

void V_OutputFrameAndSync();
void V_Init();
void V_UpdateWindowAndInput();

#endif
