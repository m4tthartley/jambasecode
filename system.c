//
//  Created by Matt Hartley on 23/02/2025.
//  Copyright 2025 GiantJelly. All rights reserved.
//

#include <core/core.h>
#include <core/core.c>
#include "system.h"
#include "render.h"
#include "bitmap.c"

sys_t sys;

void S_Init() {
	sys.running = TRUE;
	V_Init();

	sys.assertMemory = virtual_heap_allocator(MB(1), MB(1));
	sys.testBitmap = LoadBitmap(&sys.assertMemory, "assets/test.bmp");
}

vec2_t boxPos = {4, 0};
vec2_t boxSpeed = {1, 1};

void S_Update() {
	V_UpdateWindowAndInput();
	
	R_DrawNoiseBackground();
	R_DrawQuad(vec2(0, 0), vec2(5.0f, 5.0f), 0xFFFF00FF);
	R_DrawQuadOutline(vec2(-5, -2), vec2(3.0f, 5.0f), 0xFF0000FF);

	boxPos.x += 0.1f * boxSpeed.x;
	boxPos.y += 0.1f * boxSpeed.y;
	if (boxPos.x < -12.0f) {
		boxPos.x = -12.0f;
		boxSpeed.x *= -1.0f;
	}
	if (boxPos.x+4.0f > 12.0f) {
		boxPos.x = 12.0f-4.0f;
		boxSpeed.x *= -1.0f;
	}
	if (boxPos.y < -12.0f) {
		boxPos.y = -12.0f;
		boxSpeed.y *= -1.0f;
	}
	if (boxPos.y+4.0f > 12.0f) {
		boxPos.y = 12.0f-4.0f;
		boxSpeed.y *= -1.0f;
	}
	R_DrawQuad(boxPos, vec2f(4), 0xFFFF0000);

	R_BlitBitmap(sys.testBitmap, vec2(0, 0));

	V_OutputFrameAndSync();
}