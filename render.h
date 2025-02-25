//
//  Created by Matt Hartley on 24/02/2025.
//  Copyright 2025 GiantJelly. All rights reserved.
//

#ifndef __RENDER_H__
#define __RENDER_H__

#include <core/core.h>
#include <core/math.h>

void R_DrawNoiseBackground();
void R_DrawQuad(u32* fb, vec2_t pos, vec2_t size, vec3_t color);

#endif
