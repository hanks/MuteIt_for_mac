//
//  AppDelegate.h
//  MuteIt
//
//  Created by 周 涵 on 2014/03/29.
//  Copyright (c) 2014年 hanks. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    NSStatusItem *statusItem;
}

@property (assign) IBOutlet NSMenu *statusMenu;

@end
