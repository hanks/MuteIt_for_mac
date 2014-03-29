//
//  AppDelegate.m
//  MuteIt
//
//  Created by 周 涵 on 2014/03/29.
//  Copyright (c) 2014年 hanks. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreAudio/CoreAudio.h>

@interface AppDelegate ()
{
    AudioDeviceID defaultDeviceID;
}
@end

#define LEFT_CHANNEL 1
#define RIGHT_CHANNEL 2

@implementation AppDelegate

- (void)checkAudioHardware:(const AudioObjectPropertyAddress *)sourceAddr
{
    UInt32 dataSourceId = 0;
    UInt32 dataSourceIdSize = sizeof(UInt32);
    AudioObjectGetPropertyData(defaultDeviceID, sourceAddr, 0, NULL, &dataSourceIdSize, &dataSourceId);
    
    BOOL isMute = false;
    
    if (dataSourceId == 'ispk') {
        NSLog(@"no headphone");
        isMute = true;
    } else if (dataSourceId == 'hdpn') {
        NSLog(@"use headphone");
        isMute = false;
    }
    
    // mute system volumn when unplug header phone
    [self muteSystemVolumnWithFlag:isMute];
}

- (void)muteSystemVolumnWithFlag:(BOOL)isMute {
    if (isMute) {
//        NSLog(@"do mute");
//        Float32 volume = 0.0f;
//        [self changeVolumn:LEFT_CHANNEL volumn:volume];
//        [self changeVolumn:RIGHT_CHANNEL volumn:volume];
        system("osascript -e \"set volume output muted 1\"");
    } else {
        system("osascript -e \"set volume output muted 0\"");
    }
    
}

- (void)changeVolumn:(int)channelNum volumn:(Float32)volumn {
    AudioObjectPropertyAddress volumePropertyAddress = {
        kAudioDevicePropertyVolumeScalar,
        kAudioDevicePropertyScopeOutput,
        channelNum /*1: LEFT_CHANNEL, 2: RIGHT_CHANNEL*/
    };
    
    OSStatus result = AudioObjectSetPropertyData(defaultDeviceID,
                                                 &volumePropertyAddress,
                                                 0, NULL,
                                                 sizeof(volumn), &volumn);
    
    if (kAudioHardwareNoError != result) {
        //handel error
    }

}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // fetch volumn data
     UInt32 volumedataSize = sizeof(AudioDeviceID);
    
    // get default output device
    const AudioObjectPropertyAddress defaultAddr =
    {
        kAudioHardwarePropertyDefaultOutputDevice,
        kAudioObjectPropertyScopeGlobal,
        kAudioObjectPropertyElementMaster
    };
    
    OSStatus result = AudioObjectGetPropertyData(kAudioObjectSystemObject, &defaultAddr, 0, NULL, &volumedataSize, &defaultDeviceID);
    
    if (kAudioHardwareNoError == result) {
        // audio hardware is no problem
        
        // register output device change event
        AudioObjectPropertyAddress sourceAddr;
        sourceAddr.mSelector = kAudioDevicePropertyDataSource;
        sourceAddr.mScope = kAudioDevicePropertyScopeOutput;
        sourceAddr.mElement = kAudioObjectPropertyElementMaster;
        AudioObjectAddPropertyListenerBlock(defaultDeviceID, &sourceAddr, dispatch_get_current_queue(), ^(UInt32 inNumberAddresses, const AudioObjectPropertyAddress *inAddresses) {
            [self checkAudioHardware:inAddresses];
        });
        
        // fist time to detect output device
        [self checkAudioHardware:&sourceAddr];
    }
    
}

@end