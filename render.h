//
//  Created by Matt Hartley on 24/02/2025.
//  Copyright 2025 GiantJelly. All rights reserved.
//

#ifndef __RENDER_H__
#define __RENDER_H__

#include <core/core.h>
#include <core/math.h>
#include "bitmap.h"

#define R_FUNC

R_FUNC void R_DrawFbmBackground();
R_FUNC void R_DrawNoiseBackground();
R_FUNC void R_DrawQuad(vec2_t pos, vec2_t size, u32 color);
R_FUNC void R_DrawQuadOutline(vec2_t pos, vec2_t size, u32 color);
R_FUNC void R_BlitBitmap(bitmap_t* bitmap, vec2_t pos);

#endif
