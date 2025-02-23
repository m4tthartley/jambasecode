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
} video_state_t;

void V_InitMetal();
void V_OutputFrame();
video_state_t video;

@interface MetalView : NSView <NSWindowDelegate>
@end
@implementation MetalView
- (instancetype) initWithFrame: (NSRect) frame {
	self = [super initWithFrame: frame];
	if (self) {
		V_InitMetal();
		self.wantsLayer = YES;
		self.layer = video.metalLayer;
	}

	// [NSTimer scheduledTimerWithTimeInterval: 1.0/60.0
	// 	target: self
	// 	selector: @selector(triggerDraw)
	// 	userInfo: nil
	// 	repeats: YES
	// ];
	return self;
}
// - (void) draw {
// 	V_OutputFrame();
// }
// - (void) displayLayer: (CALayer*) layer {
// 	V_OutputFrame();
// }
// - (BOOL) wantsUpdateLayer {
// 	return YES;
// }
// - (CALayer*) makeBackingLayer {
// 	return video.metalLayer;
// }
- (BOOL) acceptsFirstResponder {
	return YES;
}

- (void) windowWillClose: (NSNotification*) notification {
	exit(1);
}
@end

// @interface AppDelegate : NSObject <NSApplicationDelegate>
// @property (strong, nonatomic) NSWindow* window;
// @end
// @implementation AppDelegate
// - (void) applicationDidFinishLaunching:(NSNotification*)notification {
// 	NSRect frame = NSMakeRect(100, 100, 800, 600);
// 	video.window = [
// 		[NSWindow alloc] initWithContentRect: frame
// 		styleMask: NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable
// 		backing: NSBackingStoreBuffered
// 		defer: NO
// 	];

// 	MetalView* metalView = [[MetalView alloc] initWithFrame: frame];
// 	video.window.contentView = metalView;
// 	[video.window makeKeyAndOrderFront: nil];
// }
// @end

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

void V_InitMetal() {
	video.device = MTLCreateSystemDefaultDevice();
	video.metalLayer = [CAMetalLayer layer];
	video.metalLayer.device = video.device;
	video.metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
	video.metalLayer.framebufferOnly = YES;
	video.metalLayer.frame = video.window.contentView.bounds;
	video.metalLayer.drawableSize = video.window.contentView.bounds.size;

	video.commandQueue = [video.device newCommandQueue];
	NSError* error = NULL;

	id<MTLLibrary> lib = [video.device 
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
	desc.colorAttachments[0].pixelFormat = video.metalLayer.pixelFormat;
	video.pipeline = [video.device newRenderPipelineStateWithDescriptor: desc error: &error];
	if (!video.pipeline) {
		print_error((char*)[[error localizedDescription] UTF8String]);
		exit(1);
	}

	MTLTextureDescriptor* texDesc = [[MTLTextureDescriptor alloc] init];
	texDesc.pixelFormat = video.metalLayer.pixelFormat;
	texDesc.width = video.screenSize.x;
	texDesc.height = video.screenSize.y;
	texDesc.usage = MTLTextureUsageShaderRead;
	texDesc.textureType = MTLTextureType2D;
	video.framebufferTexture = [video.device newTextureWithDescriptor: texDesc];
}

void V_OutputFrame() {
	static int index = 0;
	FOR (i, video.framebufferSize.x*video.framebufferSize.y) {
		// u8 c = randf() * 255.0f;
		// video.framebuffer[i] = 255<<24 | c<<16 | 0<<8 | 0<<0;
		float x = (float)(i%video.framebufferSize.x + index) * 0.1f;
		float y = (float)((int)(i+(index*video.framebufferSize.x))/video.framebufferSize.x) * 0.1f;
		u8 c = fbm(vec2(x, y)) * 255.0f;
		x *= 0.5f;
		y *= 0.5f;
		u8 c2 = fbm(vec2(x, y)) * 255.0f;
		c = c/2 + c2/2;
		video.framebuffer[i] = 255<<24 | c<<16 | 0<<8 | 0<<0;
	}
	++index;
	index %= (video.framebufferSize.x*video.framebufferSize.y);

	FOR (iy, video.screenSize.y)
	FOR (ix, video.screenSize.x) {
		int x = ((float)ix / video.screenSize.x) * (float)video.framebufferSize.x;
		int y = ((float)iy / video.screenSize.y) * (float)video.framebufferSize.y;
		video.scaledFramebuffer[iy*video.screenSize.x+ix] = video.framebuffer[y*video.framebufferSize.x+x];
	}

	MTLRegion region = {
		.origin = {0, 0, 0,},
		.size = {video.screenSize.x, video.screenSize.y, 1},
	};
	[video.framebufferTexture
		replaceRegion: region
		mipmapLevel: 0
		withBytes: video.scaledFramebuffer
		bytesPerRow: sizeof(u32) * video.screenSize.x
	];

	id<CAMetalDrawable> drawable = [video.metalLayer nextDrawable];
	// MTLRenderPassDescriptor* pass = [MTLRenderPassDescriptor renderPassDescriptor];
	// pass.colorAttachments[0].texture = drawable.texture;
	// pass.colorAttachments[0].loadAction = MTLLoadActionClear;
	// pass.colorAttachments[0].clearColor = MTLClearColorMake(0, 0.5, 0, 1);
	// pass.colorAttachments[0].storeAction = MTLStoreActionStore;

	id<MTLCommandBuffer> commandBuffer = [video.commandQueue commandBuffer];
	// id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor: pass];
	// [encoder setRenderPipelineState: video.pipeline];

	// [encoder setFragmentTexture: video.framebufferTexture atIndex:0];
	// [encoder drawPrimitives: MTLPrimitiveTypeTriangle vertexStart: 0 vertexCount: 3];

	// [encoder endEncoding];

	id<MTLBlitCommandEncoder> blitEncoder = [commandBuffer blitCommandEncoder];
	[blitEncoder 
		copyFromTexture: video.framebufferTexture
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

void V_Init() {
	video.screenSize = int2(1280, 720);
	video.framebufferSize = int2(320, 200);
	video.framebuffer = malloc(sizeof(u32) * video.framebufferSize.x * video.framebufferSize.y);
	video.scaledFramebuffer = malloc(sizeof(u32) * video.screenSize.x * video.screenSize.y);

	video.app = [NSApplication sharedApplication];
	[video.app setActivationPolicy: NSApplicationActivationPolicyRegular];
	// AppDelegate* delegate = [[AppDelegate alloc] init];
	// [video.app setDelegate: delegate];
	// [video.app run];

	NSRect frame = NSMakeRect(0, 0, video.screenSize.x, video.screenSize.y);
	video.window = [
		[NSWindow alloc] initWithContentRect: frame
		styleMask: NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable
		backing: NSBackingStoreBuffered
		defer: NO
	];

	MetalView* metalView = [[MetalView alloc] initWithFrame: frame];
	// video.window.contentView = metalView;
	[video.window setContentView: metalView];
	[video.window setDelegate: metalView];
	[video.window center];
	[video.window makeKeyAndOrderFront: nil];
	[video.app activateIgnoringOtherApps: YES];

	time_t startTime = system_time();

	for (;;) {
		NSEvent* event;
		while ((event = [video.app nextEventMatchingMask: NSEventMaskAny untilDate: nil inMode: NSDefaultRunLoopMode dequeue: YES])) {
			print("event %i", event.type);
			if (event.type == NSEventTypeApplicationDefined) {
				exit(1);
			}
			[video.app sendEvent: event];
			[video.app updateWindows];
		}

		V_OutputFrame();
	}
}