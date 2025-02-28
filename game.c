//
//  Created by Matt Hartley on 23/02/2025.
//  Copyright 2025 GiantJelly. All rights reserved.
//

#include <core/core.h>
#include <core/core.c>
#include "game.h"
// #include "system.h"
#include "render.h"
#include "bitmap.c"

sys_t sys;

file_data_t* ReadEntireFile(allocator_t* allocator, char* filename) {
	file_data_t* result = NULL;

	file_t file = file_open(filename);
	if (file) {
		stat_t info = file_stat(file);
		result = alloc_memory(allocator, sizeof(file_data_t)+info.size);
		copy_memory(result, &info, sizeof(info));
		file_read(file, 0, result+1, info.size);
		file_close(file);
	}

	return result;
}

void G_Init() {
	sys.running = TRUE;
	Sys_InitWindow();
	Sys_InitMetal();

	Sys_InitAudio(NULL);

	// Sys_Init()

	// window_t window = Sys_InitWindow()
	// Sys_InitInput()
	// Sys_PollEvents()

	// WindowInit()

	sys.assertMemory = virtual_heap_allocator(MB(10), NULL);
	sys.testBitmap = LoadBitmap(&sys.assertMemory, "assets/test.bmp");

	sys.pianoTest = Sys_LoadWave(&sys.assertMemory, ReadEntireFile(&sys.assertMemory, "/Users/matt/Desktop/piano.wav"));
	Sys_QueueSound(sys.pianoTest, 0.5f);
}

vec2_t boxPos = {4, 0};
vec2_t boxSpeed = {1, 1};

void G_Update() {
	Sys_PollEvents();
	
	R_DrawNoiseBackground();
	R_DrawQuad(vec2(0, 0), vec2(5.0f, 5.0f), 0xFFFF00FF);
	R_DrawQuadOutline(vec2(-5, -2), vec2(3.0f, 5.0f), 0xFF0000FF);

	boxPos.x += 0.05f * boxSpeed.x;
	boxPos.y += 0.05f * boxSpeed.y;
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
	R_DrawQuad(boxPos, vec2f(4), 0xFFFFFF00);

	R_BlitBitmap(sys.testBitmap, vec2(0, 0));

	Sys_OutputFrameAndSync();
}