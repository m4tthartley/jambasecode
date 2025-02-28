//
//  Created by Matt Hartley on 23/02/2025.
//  Copyright 2025 GiantJelly. All rights reserved.
//

#ifndef __GAME_H__
#define __GAME_H__

#include <core/core.h>
#include "system.h"
#include "bitmap.h"

typedef struct {
	b32 running;
	allocator_t assertMemory;

	bitmap_t* testBitmap;
	sys_wave_t* pianoTest;

	u8 objc_state[128];
} sys_t;

void G_Init();
void G_Update();

#endif
