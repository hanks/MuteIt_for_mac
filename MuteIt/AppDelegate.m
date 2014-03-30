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
        // no headphone
        isMute = true;
    } else if (dataSourceId == 'hdpn') {
        // use headphone
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

- (IBAction)quit:(id)sender {
    [[NSApplication sharedApplication] terminate:nil];
}

- (IBAction)runOnStartup:(id)sender {
    [sender setState:![sender state]];
    
    if ([sender state]) {
        // if true to add app to login item lists
        [self addAppAsLoginItem];
    } else {
        // delete from login item lists
        [self deleteAppFromLoginItem];
    }
}

- (void)awakeFromNib {
    // add status icon to system menu bar
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:_statusMenu];
    NSImage *icon = [NSImage imageNamed:@"icon_16x16.png"];
    [statusItem setImage:icon];
    [statusItem setToolTip:@"MuteIt!"];
    [statusItem setHighlightMode:YES];
}

-(void) addAppAsLoginItem{
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
    
	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:appPath]);
    
	// Create a reference to the shared file list.
    // We are adding it to the current user only.
    // If we want to add it all users, use
    // kLSSharedFileListGlobalLoginItems instead of
    //kLSSharedFileListSessionLoginItems
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems, NULL);
	if (loginItems) {
		//Insert an item to the list.
		LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems,
                                                                     kLSSharedFileListItemLast, NULL, NULL,
                                                                     url, NULL, NULL);
		if (item){
			CFRelease(item);
        }
	}
    
	CFRelease(loginItems);
}

-(void) deleteAppFromLoginItem{
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
    
	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:appPath]);
    
	// Create a reference to the shared file list.
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems, NULL);
    
	if (loginItems) {
		UInt32 seedValue;
		//Retrieve the list of Login Items and cast them to
		// a NSArray so that it will be easier to iterate.
		NSArray  *loginItemsArray = (NSArray *)CFBridgingRelease(LSSharedFileListCopySnapshot(loginItems, &seedValue));
		for(int i = 0 ; i< [loginItemsArray count]; i++){
			LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)CFBridgingRetain([loginItemsArray
                                                                        objectAtIndex:i]);
			//Resolve the item with URL
			if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
				NSString * urlPath = [(NSURL*)CFBridgingRelease(url) path];
				if ([urlPath compare:appPath] == NSOrderedSame){
					LSSharedFileListItemRemove(loginItems,itemRef);
				}
			}
		}
	}
}
@end