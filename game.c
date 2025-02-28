//
//  Created by Matt Hartley on 23/02/2025.
//  Copyright 2025 GiantJelly. All rights reserved.
//

#include <core/core.h>
#include <core/core.c>
#include "core/platform.h"
#include "game.h"
#include "render.h"
#include "bitmap.h"
#include "font.c"
#include "system.h"

sys_t sys;
extern video_t video;

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

	float aspect = (float)video.framebufferSize.x / (float)video.framebufferSize.y;
	video.worldSpaceMin = (vec2_t){-10.0f * aspect, -10.0f};
	video.worldSpaceMax = (vec2_t){10.0f * aspect, 10.0f};
	video.worldSpace = (vec2_t){(float)video.framebufferSize.x / 8.0f, (float)video.framebufferSize.y / 8.0f};

	sys.assetMemory = virtual_heap_allocator(MB(10), NULL);
	sys.scratchBuffer = virtual_bump_allocator(MB(1), NULL);

	sys.testBitmap = LoadBitmap(&sys.assetMemory, "assets/test.bmp");

	sys.fontBitmap = Fnt_GenBitmap(&sys.assetMemory, &FONT_DEFAULT);

	// sys.pianoTest = Sys_LoadWave(&sys.assetMemory, ReadEntireFile(&sys.assetMemory, "/Users/matt/Desktop/piano.wav"));
	// Sys_QueueSound(sys.pianoTest, 0.5f);
}

vec2_t boxPos = {4, 0};
vec2_t boxSpeed = {1, 1};

R_FUNC void R_BlitFontBitmaps(bitmap_t* bitmap, font_text_t* text, vec2_t pos) {
	FOR (i, text->numChars) {
		font_text_char_t* c = text->chars + i;
		R_BlitBitmapAtlas(
			bitmap,
			c->index%16 * 8,
			c->index/16 * 8,
			8,
			8,
			add2(pos, c->pos)
		);
	}
}

void G_Update() {
	Sys_PollEvents();
	
	R_DrawNoiseBackground();
	R_DrawQuad(vec2(2, 2), vec2(5.0f, 5.0f), 0xFFFF00FF);
	// R_DrawQuadOutline(vec2(-5, -2), vec2(3.0f, 5.0f), 0xFF0000FF);

	// R_DrawQuad(vec2(0, 0), vec2(1.0f, 1.0f), 0xFFFF00FF);
	// R_DrawQuad(vec2(2, 0), vec2(1.0f, 1.0f), 0xFFFF00FF);
	// R_DrawQuad(vec2(4, 0), vec2(1.0f, 1.0f), 0xFFFF00FF);
	// R_DrawQuad(vec2(1, 1), vec2(1.0f, 1.0f), 0xFFFF00FF);

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

	char* testStr = "Old Tom Bombadil is a merry fellow\nBright blue his jacket is and his boots are yellow\nReeds by the shady pool, lilies on the water\nOld Tom Bombadil and the river-daughter";
	font_text_t* text = Fnt_Text(&sys.scratchBuffer, &FONT_DEFAULT, testStr, (font_settings_t){20});
	R_BlitFontBitmaps(sys.fontBitmap, text, vec2(-19.0f, 10.0f));
	
	// clear_allocator(&sys.scratchBuffer);
	sys.scratchBuffer.stackptr = 0;
	zero_memory(sys.scratchBuffer.address, sys.scratchBuffer.size);
	Sys_OutputFrameAndSync();
}