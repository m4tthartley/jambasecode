//
//  Created by Matt Hartley on 23/02/2025.
//  Copyright 2025 GiantJelly. All rights reserved.
//

#include <core/core.h>
#include <core/core.c>
#include "system.h"
#include "render.h"

system_t sys;

void S_Init() {
	sys.running = TRUE;
	V_Init();
}

void S_Update() {
	V_UpdateWindowAndInput();
	
	R_DrawNoiseBackground();

	V_OutputFrameAndSync();
}