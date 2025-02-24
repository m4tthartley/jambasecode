//
//  Video Header
//
//  Created by Matt Hartley on 22/02/2025.
//  Copyright 2025 GiantJelly. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/CAMetalLayer.h>
#import <Metal/Metal.h>
#include <core/core.h>
#include <core/math.h>

typedef struct {
	NSApplication* app;
	NSWindow* window;
	id<MTLDevice> device;
	CAMetalLayer* metalLayer;
	id<MTLCommandQueue> commandQueue;
	id<MTLRenderPipelineState> pipeline;

	int2_t screenSize;
	int2_t framebufferSize;

	id<MTLTexture> framebufferTexture;
	u32* framebuffer;
	u32* scaledFramebuffer;
} video_t;

void V_Init();
