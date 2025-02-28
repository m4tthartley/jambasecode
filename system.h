//
//  Video Header
//
//  Created by Matt Hartley on 22/02/2025.
//  Copyright 2025 GiantJelly. All rights reserved.
//

#ifndef __SYSTEM_H__
#define __SYSTEM_H__

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

	vec2_t worldSpaceMin;
	vec2_t worldSpaceMax;
	vec2_t worldSpace;
} video_t;

typedef struct {
	union {
		i16 channels[2];
		struct {
			i16 left;
			i16 right;
		};
	};
} sys_audio_sample_t;
typedef struct {
	int channels;
	int samplesPerSecond;
	int bytesPerSample;
	size_t sampleCount;
	sys_audio_sample_t data[];
} sys_wave_t;

typedef struct {
	sys_wave_t* wave;
	float cursor;
	float volume;
} sys_sound_t;

typedef void (*audio_mixer_proc)(void* outputStream, int sampleCount, void* userdata);

#define SYS_FUNC

SYS_FUNC void Sys_InitMetal();
SYS_FUNC void Sys_OutputFrameAndSync();
SYS_FUNC void Sys_InitWindow();
// SYS_FUNC void Sys_InitMetal();
SYS_FUNC void Sys_PollEvents();

SYS_FUNC void Sys_QueueSound(sys_wave_t* wave, float volume);
SYS_FUNC void Sys_InitAudio(audio_mixer_proc mixerProc);
SYS_FUNC sys_wave_t* Sys_LoadWave(allocator_t* allocator, file_data_t* fileData);

#endif
