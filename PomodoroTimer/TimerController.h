//
//  TimerController.h
//  PomodoroTimer
//
//  Created by Frantic on 11-05-02.
//  Copyright 2013 Alexander Kotliarskyi. All rights reserved.
//

#import <Foundation/Foundation.h>

enum TimerState {
    TSReady,
    TSRunning,
    TSFinished
};

@interface TimerController : NSObject {
    NSStatusItem *statusItem;
    NSMenu *menu;
    NSMenuItem *menuItemStatus;
    NSMenuItem *menuItemInterrupt;
    NSMenuItem *menuItemStart;
    NSWindow *hudWindow;
    NSTextField *hudLabel;
    int timerState;
    NSDate *endDate;
}

@property (assign) IBOutlet NSMenu *menu;
@property (assign) IBOutlet NSMenuItem *menuItemStatus;
@property (assign) IBOutlet NSMenuItem *menuItemInterrupt;
@property (assign) IBOutlet NSMenuItem *menuItemStart;
@property (assign) IBOutlet NSWindow *hudWindow;
@property (assign) IBOutlet NSTextField *hudLabel;
@property (nonatomic, assign) int timerState;
@property (retain) NSDate *endDate;
@property (readonly) NSTimeInterval timeInterval;

- (IBAction)startTimer:(id)sender;
- (IBAction)interruptTimer:(id)sender;

- (void)showHUDWithText:(NSString *)text;
- (void)hideHUD;

@end
