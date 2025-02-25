//
//  Created by Matt Hartley on 24/02/2025.
//  Copyright 2025 GiantJelly. All rights reserved.
//

#include <core/core.h>
#include <core/math.h>
#include "video.h"

extern video_t video;

void R_DrawNoiseBackground() {
	u32* fb = video.framebuffer;
	int2_t framebufferSize = video.framebufferSize;
	static int index = 0;
	FOR (i, framebufferSize.x*framebufferSize.y) {
		float x = (float)(i%framebufferSize.x + index) * 0.1f;
		float y = (float)((int)(i+(index*framebufferSize.x))/framebufferSize.x) * 0.1f;
		u8 c = fbm(vec2(x, y)) * 255.0f;
		x *= 4.0f;
		y *= 4.0f;
		u8 c2 = fbm(vec2(x, y)) * 255.0f;
		x *= 4.0f;
		y *= 4.0f;
		u8 c3 = fbm(vec2(x, y)) * 255.0f;
		c = c/3 + c2/3 + c3/3;
		fb[i] = 255<<24 | 0<<16 | (c)<<8 | (0)<<0;
	}
	++index;
	index %= (framebufferSize.x*framebufferSize.y);
}

vec2_t worldSpaceMin = {-10.0f, -10.0f};
vec2_t worldSpaceMax = {10.0f, 10.0f};

void R_DrawQuad(vec2_t pos, vec2_t size, u32 color) {
	u32* fb = video.framebuffer;

	int2_t screenPos = {
		(pos.x-worldSpaceMin.x) / (worldSpaceMax.x-worldSpaceMin.x) * (float)video.framebufferSize.x,
		(pos.y-worldSpaceMin.y) / (worldSpaceMax.y-worldSpaceMin.y) * (float)video.framebufferSize.y,
	};
	int2_t screenSize = {
		(size.x) / (worldSpaceMax.x-worldSpaceMin.x) * (float)video.framebufferSize.x,
		(size.y) / (worldSpaceMax.y-worldSpaceMin.y) * (float)video.framebufferSize.y,
	};

	// clip
	if (screenPos.x >= video.framebufferSize.x ||
		screenPos.x+screenSize.x < 0 ||
		screenPos.y >= video.framebufferSize.y ||
		screenPos.y+screenSize.y < 0) {
		// cull
		return;
	}
	if (screenPos.x < 0) {
		screenSize.x -= screenPos.x;
		screenPos.x = 0;
	}
	if (screenPos.y < 0) {
		screenSize.y -= screenPos.y;
		screenPos.y = 0;
	}
	if ((screenPos.x+screenSize.x) >= video.framebufferSize.x) {
		screenSize.x = video.framebufferSize.x - screenPos.x;
	}
	if ((screenPos.y+screenSize.y) >= video.framebufferSize.y) {
		screenSize.y = video.framebufferSize.y - screenPos.y;
	}

	// int2_t i2 = {}
	FOR (y, screenSize.y)
	FOR (x, screenSize.x) {
		int index = (screenPos.y+y)*video.framebufferSize.x + (screenPos.x+x);
		fb[index] = color;
	}
}

void R_DrawQuadOutline(vec2_t pos, vec2_t size, u32 color) {
	u32* fb = video.framebuffer;

	int2_t screenPos = {
		(pos.x-worldSpaceMin.x) / (worldSpaceMax.x-worldSpaceMin.x) * (float)video.framebufferSize.x,
		(pos.y-worldSpaceMin.y) / (worldSpaceMax.y-worldSpaceMin.y) * (float)video.framebufferSize.y,
	};
	int2_t screenSize = {
		(size.x) / (worldSpaceMax.x-worldSpaceMin.x) * (float)video.framebufferSize.x,
		(size.y) / (worldSpaceMax.y-worldSpaceMin.y) * (float)video.framebufferSize.y,
	};

	// clip
	if (screenPos.x >= video.framebufferSize.x ||
		screenPos.x+screenSize.x < 0 ||
		screenPos.y >= video.framebufferSize.y ||
		screenPos.y+screenSize.y < 0) {
		// cull
		return;
	}
	if (screenPos.x < 0) {
		screenSize.x -= screenPos.x;
		screenPos.x = 0;
	}
	if (screenPos.y < 0) {
		screenSize.y -= screenPos.y;
		screenPos.y = 0;
	}
	if ((screenPos.x+screenSize.x) >= video.framebufferSize.x) {
		screenSize.x = video.framebufferSize.x - screenPos.x;
	}
	if ((screenPos.y+screenSize.y) >= video.framebufferSize.y) {
		screenSize.y = video.framebufferSize.y - screenPos.y;
	}

	for (int y=screenPos.y; y<screenPos.y+screenSize.y; ++y) {
		fb[y*video.framebufferSize.x + (screenPos.x + 0)] = color;
		fb[y*video.framebufferSize.x + (screenPos.x + screenSize.x - 1)] = color;
	}
	for (int x=screenPos.x; x<screenPos.x+screenSize.x; ++x) {
		fb[(screenPos.y + 0)*video.framebufferSize.x + x] = color;
		fb[(screenPos.y + screenSize.y - 1)*video.framebufferSize.x + x] = color;
	}
	// FOR (x, screenSize.x) {
	// 	int index = (screenPos.y+y)*video.framebufferSize.x + (screenPos.x+x);
	// 	fb[index] = 0xFFFF0000;
	// }

	// FOR (y, screenSize.y)
	// FOR (x, screenSize.x) {
	// 	int index = (screenPos.y+y)*video.framebufferSize.x + (screenPos.x+x);
	// 	fb[index] = color;
	// }
}
