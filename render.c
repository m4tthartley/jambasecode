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

void R_DrawQuad(u32* fb, vec2_t pos, vec2_t size, vec3_t color) {

}
