//
//  Video for Apple devices
//
//  Created by Matt Hartley on 22/02/2025.
//  Copyright 2025 GiantJelly. All rights reserved.
//

#include <AppKit/AppKit.h>
#import <Cocoa/Cocoa.h>
#import <Metal/Metal.h>
#import <QuartzCore/CAMetalLayer.h>

#include <core/core.h>
#include <core/math.h>
#include <core/math.c>

#include "system.h"
#include "game.h"


typedef struct {
	NSApplication* app;
	NSWindow* window;

	id<MTLDevice> device;
	CAMetalLayer* metalLayer;
	id<MTLCommandQueue> commandQueue;
	id<MTLRenderPipelineState> pipeline;

	id<MTLTexture> framebufferTexture;
} sys_objc_state_t;


video_t video;

extern sys_t sys;

@interface MetalView : NSView <NSWindowDelegate>
@end
@implementation MetalView

- (instancetype) initWithFrame: (NSRect) frame {
	self = [super initWithFrame: frame];
	if (self) {
		// sys_objc_state_t* state = (sys_objc_state_t*)sys.objc_state;
		// Sys_InitMetal();
		self.wantsLayer = YES;
		// self.layer = state->metalLayer;
	}

	// [NSTimer scheduledTimerWithTimeInterval: 1.0/60.0
	// 	target: self
	// 	selector: @selector(triggerDraw)
	// 	userInfo: nil
	// 	repeats: YES
	// ];
	return self;
}

@end

@interface AppDelegate : NSObject <NSWindowDelegate>
@end
@implementation AppDelegate

- (BOOL) acceptsFirstResponder {
	return YES;
}

- (void) windowWillClose: (NSNotification*) notification {
	print("Window close requested");
	exit(1);
}

- (void) applicationDidFinishLaunching:(NSNotification*)notification {
	print("applicationDidFinishLaunching");
}

@end

NSString* shaderSource =
@"#include <metal_stdlib>\n"
"using namespace metal;\n"
"struct VertexOut {\n"
"	float4 pos [[position]];\n"
"	float2 texCoord;\n"
"};\n"
"vertex VertexOut vertex_main(uint vertexID [[vertex_id]]) {\n"
"	float4 vertices[] = {\n"
"		{-0.5, -0.5, 0.0, 1.0},\n"
"		{ 0.5, -0.5, 0.0, 1.0},\n"
"		{ 0.5,  0.5, 0.0, 1.0},\n"
"		{-0.5,  0.5, 0.0, 1.0},\n"
"	};\n"
"	float2 texCoords[] = {\n"
"		{0.0, 0.0},\n"
"		{1.0, 0.0},\n"
"		{1.0, 1.0},\n"
"		{0.0, 1.0},\n"
"	};\n"
"	VertexOut out;\n"
"	out.pos = vertices[vertexID];\n"
"	out.texCoord = texCoords[vertexID];\n"
"	return out;\n"
"}\n"
"fragment float4 fragment_main(VertexOut in [[stage_in]], texture2d<float> texture [[texture(0)]]) {\n"
"	constexpr sampler textureSampler (mag_filter::linear, min_filter::linear);\n"
"	return texture.sample(textureSampler, in.texCoord);\n"
"	//return float4(1.0, 0.0, 1.0, 1.0);\n"
"}\n"
;

SYS_FUNC void Sys_InitMetalView() {
	sys_objc_state_t* state = (sys_objc_state_t*)sys.objc_state;

	video.framebufferSize = int2(320, 200);
	video.framebuffer = malloc(sizeof(u32) * video.framebufferSize.x * video.framebufferSize.y);
	video.scaledFramebuffer = malloc(sizeof(u32) * video.screenSize.x * video.screenSize.y);

	NSRect frame = NSMakeRect(0, 0, video.screenSize.x, video.screenSize.y);
	MetalView* metalView = [[[MetalView alloc] initWithFrame: frame] retain];
	[state->window setContentView: metalView];
}

SYS_FUNC void Sys_InitMetal() {
	sys_objc_state_t* state = (sys_objc_state_t*)sys.objc_state;

	Sys_InitMetalView();

	id<MTLDevice> device = [MTLCreateSystemDefaultDevice() retain];
	// [device retain];
	state->device = device;
	state->metalLayer = [CAMetalLayer layer];

	// CAMetalLayer* metalLayer = video.metalLayer;
	// NSWindow* window = video.window;

	state->metalLayer.device = device;
	state->metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
	state->metalLayer.framebufferOnly = YES;
	state->metalLayer.frame = state->window.contentView.bounds;
	state->metalLayer.drawableSize = state->window.contentView.bounds.size;

	state->commandQueue = [[device newCommandQueue] retain];
	// state->commandQueue = commandQueue;
	// [commandQueue retain];
	// video.commandQueue = commandQueue;
	NSError* error = NULL;

	id<MTLLibrary> lib = [device 
		newLibraryWithSource: shaderSource
		options:nil
		error:&error];
	if (!lib) {
		print_error((char*)[[error localizedDescription] UTF8String]);
		exit(1);
	}

	id<MTLFunction> vertex = [lib newFunctionWithName: @"vertex_main"];
	id<MTLFunction> fragment = [lib newFunctionWithName: @"fragment_main"];
	MTLRenderPipelineDescriptor* desc = [[MTLRenderPipelineDescriptor alloc] init];
	// desc.rasterSampleCount = 1;
	desc.vertexFunction = vertex;
	desc.fragmentFunction = fragment;
	desc.colorAttachments[0].pixelFormat = state->metalLayer.pixelFormat;
	state->pipeline = [[device
		newRenderPipelineStateWithDescriptor: desc
		error: &error
	] retain];
	if (!state->pipeline) {
		print_error((char*)[[error localizedDescription] UTF8String]);
		exit(1);
	}
	// video.pipeline = pipeline;

	[lib release];
	[vertex release];
	[fragment release];
	[desc release];

	MTLTextureDescriptor* texDesc = [[MTLTextureDescriptor alloc] init];
	texDesc.pixelFormat = state->metalLayer.pixelFormat;
	texDesc.width = video.screenSize.x;
	texDesc.height = video.screenSize.y;
	texDesc.usage = MTLTextureUsageShaderRead;
	texDesc.textureType = MTLTextureType2D;
	state->framebufferTexture = [[device newTextureWithDescriptor: texDesc] retain];
	[texDesc release];
	// state->framebufferTexture = texture;

	state->window.contentView.layer = state->metalLayer;
}

SYS_FUNC void Sys_OutputFrameAndSync() {
	sys_objc_state_t* state = (sys_objc_state_t*)sys.objc_state;

	// id<MTLTexture> framebufferTexture = video.framebufferTexture;
	// CAMetalLayer* metalLayer = video.metalLayer;
	// id<MTLCommandQueue> commandQueue = video.commandQueue;

	// Scale framebuffer up to window framebuffer size
	float xd = (float)video.framebufferSize.x / (float)video.screenSize.x;
	float yd = (float)video.framebufferSize.y / (float)video.screenSize.y;
	float diff = xd / yd;
	int relativeWidth = ((float)video.screenSize.y / (float)video.framebufferSize.y) * (float)video.framebufferSize.x; //(float)video.screenSize.x * diff;
	int xoffset = (video.screenSize.x-relativeWidth)/2;
	for (int iy=0; iy<video.screenSize.y; ++iy)
	for (int ix=xoffset; ix<xoffset+relativeWidth; ++ix) {
		int x = ((float)(ix-xoffset) / relativeWidth) * (float)video.framebufferSize.x;
		int y = ((float)(iy) / video.screenSize.y) * (float)video.framebufferSize.y;
		video.scaledFramebuffer[iy*video.screenSize.x+ix] = video.framebuffer[(video.framebufferSize.y-y-1)*video.framebufferSize.x+x];
	}

	MTLRegion region = {
		.origin = {0, 0, 0,},
		.size = {video.screenSize.x, video.screenSize.y, 1},
	};
	[state->framebufferTexture
		replaceRegion: region
		mipmapLevel: 0
		withBytes: video.scaledFramebuffer
		bytesPerRow: sizeof(u32) * video.screenSize.x
	];

	id<CAMetalDrawable> drawable = [state->metalLayer nextDrawable];
	// MTLRenderPassDescriptor* pass = [MTLRenderPassDescriptor renderPassDescriptor];
	// pass.colorAttachments[0].texture = drawable.texture;
	// pass.colorAttachments[0].loadAction = MTLLoadActionClear;
	// pass.colorAttachments[0].clearColor = MTLClearColorMake(0, 0.5, 0, 1);
	// pass.colorAttachments[0].storeAction = MTLStoreActionStore;

	id<MTLCommandBuffer> commandBuffer = [state->commandQueue commandBuffer];
	// id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor: pass];
	// [encoder setRenderPipelineState: video.pipeline];

	// [encoder setFragmentTexture: video.framebufferTexture atIndex:0];
	// [encoder drawPrimitives: MTLPrimitiveTypeTriangle vertexStart: 0 vertexCount: 3];

	// [encoder endEncoding];

	id<MTLBlitCommandEncoder> blitEncoder = [commandBuffer blitCommandEncoder];
	[blitEncoder 
		copyFromTexture: state->framebufferTexture
		sourceSlice: 0
		sourceLevel: 0
		sourceOrigin: (MTLOrigin){0, 0, 0}
		sourceSize: (MTLSize){video.screenSize.x, video.screenSize.y, 1}
		toTexture: drawable.texture
		destinationSlice: 0
		destinationLevel: 0
		destinationOrigin: (MTLOrigin){0, 0, 0}
	];
	[blitEncoder endEncoding];

	[commandBuffer presentDrawable: drawable];
	[commandBuffer commit];
}

SYS_FUNC void Sys_InitWindow() {
	int sys_objc_state_size = sizeof(sys_objc_state_t);
	assert(sizeof(sys.objc_state) >= sys_objc_state_size);
	sys_objc_state_t* state = (sys_objc_state_t*)sys.objc_state;

	state->app = [NSApplication sharedApplication];
	// video.app = app;
	[state->app setActivationPolicy: NSApplicationActivationPolicyRegular];
	// AppDelegate* delegate = [[AppDelegate alloc] init];
	// [video.app setDelegate: delegate];
	// [video.app run];

	// 320x200
	// 640x400
	// 1280x800
	video.screenSize = int2(1280, 800);
	NSRect frame = NSMakeRect(0, 0, video.screenSize.x, video.screenSize.y);
	state->window = [[
		[NSWindow alloc] initWithContentRect: frame
		styleMask: NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable
		backing: NSBackingStoreBuffered
		defer: NO
	] retain];
	// video.window = window;

	AppDelegate* delegate = [[[AppDelegate alloc] init] retain];
	[state->window setDelegate: delegate];
	// NSRect frame = NSMakeRect(0, 0, video.screenSize.x, video.screenSize.y);
	[state->window center];
	[state->window makeKeyAndOrderFront: nil];
	[state->app activateIgnoringOtherApps: YES];

	time_t startTime = system_time();

	// for (;;) {
	// 	V_UpdateWindow();

	// 	V_OutputFrameAndSync();
	// }
}

// SYS_FUNC void Sys_InitMetal() {
	
// }

SYS_FUNC void Sys_PollEvents() {
	sys_objc_state_t* state = (sys_objc_state_t*)sys.objc_state;
	// NSApplication* app = video.app;

	NSEvent* event;
	while ((event = [state->app nextEventMatchingMask: NSEventMaskAny untilDate: nil inMode: NSDefaultRunLoopMode dequeue: YES])) {
		// print("event %i", event.type);
		if (event.type == NSEventTypeApplicationDefined) {
			exit(1);
		}
		[state->app sendEvent: event];
		[state->app updateWindows];
	}
}
