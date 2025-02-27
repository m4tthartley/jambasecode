//
//  Video Header
//
//  Created by Matt Hartley on 22/02/2025.
//  Copyright 2025 GiantJelly. All rights reserved.
//

// #import <Cocoa/Cocoa.h>
// #import <QuartzCore/CAMetalLayer.h>
// #import <Metal/Metal.h>
#include <core/core.h>
#include <core/math.h>

typedef struct {
	// /*NSApplication**/ void* app;
	// /*NSWindow**/ void* window;

	// /*id<MTLDevice>*/ void* device;
	// /*CAMetalLayer**/ void* metalLayer;
	// /*id<MTLCommandQueue>*/ void* commandQueue;
	// /*id<MTLRenderPipelineState>*/ void* pipeline;

	int2_t screenSize;
	int2_t framebufferSize;

	// /*id<MTLTexture>*/ void* framebufferTexture;
	u32* framebuffer;
	u32* scaledFramebuffer;
} video_t;

#define SYS_FUNC

SYS_FUNC void Sys_InitMetal();
SYS_FUNC void Sys_OutputFrameAndSync();
SYS_FUNC void Sys_InitWindow();
// SYS_FUNC void Sys_InitMetal();
SYS_FUNC void Sys_PollEvents();
