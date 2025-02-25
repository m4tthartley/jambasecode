//
//  Created by Matt Hartley on 23/02/2025.
//  Copyright 2025 GiantJelly. All rights reserved.
//

#include <core/core.h>
#include <core/core.c>
#include "system.h"
#include "render.h"

sys_t sys;

void S_Init() {
	sys.running = TRUE;
	V_Init();
}

void S_Update() {
	V_UpdateWindowAndInput();
	
	R_DrawNoiseBackground();
	R_DrawQuad(vec2(0, 0), vec2(5.0f, 5.0f), 0xFFFF00FF);
	R_DrawQuadOutline(vec2(-5, -2), vec2(3.0f, 5.0f), 0xFF0000FF);

	V_OutputFrameAndSync();
}