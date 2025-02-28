//
//  Created by Matt Hartley on 27/02/2025.
//  Copyright 2025 GiantJelly. All rights reserved.
//

#include <AudioToolbox/AudioToolbox.h>
#include <CoreAudioTypes/CoreAudioTypes.h>

#include "system.h"

typedef struct {
	// data
} sys_wave_t;

typedef struct {
	sys_wave_t* wave;
	float cursor;
	float volume;
} sys_sound_t;
sys_sound_t _sounds[64];
// int soundCount

SYS_FUNC void Sys_QueueSound(sys_wave_t* wave, float volume) {
	FOR (i, 64) {
		if (!_sounds[i].wave) {
			_sounds[i] = (sys_sound_t){
				.wave = wave,
				.cursor = 0,
				.volume = volume,
			};
			return;
		}
	}
	print_error("Out of sound slots");
}

OSStatus Sys_AURenderCallback(
	void* refCon,
	AudioUnitRenderActionFlags* flags,
	const AudioTimeStamp* timeStamp,
	UInt32 busNumber,
	UInt32 numFrames,
	AudioBufferList* data
) {
	static int cursor = 0;
	FOR (i, numFrames) {
		float wave = sinf(440.0f * PI2 * cursor / 44100.0f) * 0.1f;
		((float*)data->mBuffers[0].mData)[i*2] = wave;
		((float*)data->mBuffers[0].mData)[i*2+1] = wave;
		// ((float*)data->mBuffers[1].mData)[i] = wave;
		++cursor;
	}

	return noErr;
}

SYS_FUNC void Sys_InitAudio(audio_mixer_proc mixerProc) {
	AudioComponentDescription desc = {
		.componentType = kAudioUnitType_Output,
		.componentSubType = kAudioUnitSubType_DefaultOutput,
		.componentManufacturer = kAudioUnitManufacturer_Apple,
	};

	AudioComponent outputComponent = AudioComponentFindNext(NULL, &desc);
	if (!outputComponent) {
		print_error("Audio init failed: AudioComponentFindNext");
		return;
	}

	AudioUnit outputUnit;
	OSStatus status = AudioComponentInstanceNew(outputComponent, &outputUnit);
	if (status != noErr) {
		print_error("Audio init failed: AudioComponentInstanceNew");
		return;
	}

	AudioStreamBasicDescription streamDesc = {
		.mSampleRate = 44100,
		.mFormatID = kAudioFormatLinearPCM,
		.mFormatFlags = kAudioFormatFlagIsFloat | kAudioFormatFlagIsPacked,
		.mFramesPerPacket = 1,
		.mChannelsPerFrame = 2,
		.mBytesPerFrame = sizeof(float)*2,
		.mBytesPerPacket = sizeof(float)*2,
		.mBitsPerChannel = 32,
	};
	AudioUnitSetProperty(
		outputUnit,
		kAudioUnitProperty_StreamFormat,
		kAudioUnitScope_Input,
		0,
		&streamDesc,
		sizeof(streamDesc)
	);

	AURenderCallbackStruct callback;
	callback.inputProc = Sys_AURenderCallback;
	callback.inputProcRefCon = NULL;
	AudioUnitSetProperty(
		outputUnit,
		kAudioUnitProperty_SetRenderCallback,
		kAudioUnitScope_Input,
		0,
		&callback,
		sizeof(callback)
	);

	AudioUnitInitialize(outputUnit);
	AudioOutputUnitStart(outputUnit);
}
