//
//  PomodoroTimerAppDelegate.h
//  PomodoroTimer
//
//  Created by Frantic on 11-05-02.
//  Copyright 2013 Alexander Kotliarskyi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PomodoroTimerAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
