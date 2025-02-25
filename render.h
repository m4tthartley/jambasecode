//
//  Created by Matt Hartley on 24/02/2025.
//  Copyright 2025 GiantJelly. All rights reserved.
//

#ifndef __RENDER_H__
#define __RENDER_H__

#include <core/core.h>
#include <core/math.h>

void R_DrawNoiseBackground();
void R_DrawQuad(vec2_t pos, vec2_t size, u32 color);
void R_DrawQuadOutline(vec2_t pos, vec2_t size, u32 color);

#endif
