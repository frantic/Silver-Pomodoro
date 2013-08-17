//
//  TimerController.m
//  PomodoroTimer
//
//  Created by Frantic on 11-05-02.
//  Copyright 2013 Alexander Kotliarskyi. All rights reserved.
//

#import "TimerController.h"

@interface TimerController (Private)
- (void)setStatus:(NSString *)status;
- (void)statusItemClick:(id)sender;
- (void)tick;
- (void)updateTimerState;
@end

@implementation TimerController

@synthesize menu;
@synthesize menuItemStatus;
@synthesize menuItemInterrupt;
@synthesize menuItemStart;
@synthesize hudWindow;
@synthesize hudLabel;
@synthesize timerState;
@synthesize endDate;

- (void)awakeFromNib
{
    statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
    [statusItem setHighlightMode:YES];
    [statusItem setTarget:self];
    [statusItem setAction:@selector(statusItemClick:)];
    self.timerState = TSReady;
    
    hudWindow.alphaValue = 0.0;
    [hudWindow setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces];
    
    //
    // Reliable timer implementation. [NSTimer scheduledTimer:....] doesn't fire 
    // while menu is opened
    //
    dispatch_queue_t queue = dispatch_queue_create("Timer", NULL);
    dispatch_async(queue, ^(void) {
        while (YES) {
            [NSThread sleepForTimeInterval:1.0];
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self tick];
            });
        }
    });
    dispatch_release(queue);
}

- (void)statusItemClick:(id)sender
{
    if (timerState == TSFinished) {
        [self setTimerState:TSReady];
    } else {
        [statusItem popUpStatusItemMenu:menu];
    }
}

- (void)setStatus:(NSString *)status
{
    [menuItemStatus setTitle:status];
}
     
- (void)setTimerState:(int)newTimerState
{
    timerState = newTimerState;
    [self updateTimerState];
}

- (void)updateTimerState
{
    switch (timerState) {
        case TSReady:
            [statusItem setImage:nil];
            [statusItem setTitle:@"--:--"];
            [menuItemStart setHidden:NO];
            [menuItemInterrupt setHidden:YES];
            [self setStatus:@"Status: Ready"];
            break;
        
        case TSRunning:
            [statusItem setImage:nil];
            [statusItem setTitle:@"--:--"];
            [menuItemStart setHidden:YES];
            [menuItemInterrupt setHidden:NO];
            [self setStatus:@"..."];
            break;
            
        case TSFinished:
            [statusItem setImage:nil];
            [statusItem setTitle:@"Done!"];
            [self setStatus:@"Another pomodoro finished! Wooohoo!"];
            [self showHUDWithText:@"Time is up!"];
            break;
            
        default:
            break;
    }
}

- (void)tick
{
    if (timerState == TSRunning) {
        NSDateComponents *cmp = [[NSCalendar currentCalendar] components:NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:[NSDate date] toDate:self.endDate options:0];
        
        NSInteger min = [cmp minute];
        NSInteger sec = [cmp second];
        if (min <= 0 && sec <= 0) {
            [self setTimerState:TSFinished];
        } else {
            //
            // Display minutes and seconds, that left to the end of pomodoro
            //
            NSString *timeLeftStr = nil;
            if (sec == 0)
                timeLeftStr = [NSString stringWithFormat:@"%ld min", min];
            else if (min == 0)
                timeLeftStr = [NSString stringWithFormat:@"%ld sec", sec];
            else
                timeLeftStr = [NSString stringWithFormat:@"%ld min %ld sec", min, sec];
            
            [self setStatus:[NSString stringWithFormat:@"Remaining time: %@", timeLeftStr]];
            //
            // Main timer display: seconds should have leading zero
            //
            NSString *secPrefix = sec < 10 ? @"0" : @"";
            [statusItem setTitle:[NSString stringWithFormat:@"%ld:%@%ld", min, secPrefix, sec]];
        }
    }
}

- (IBAction)startTimer:(id)sender
{
    self.endDate = [NSDate dateWithTimeIntervalSinceNow:self.timeInterval];
    self.timerState = TSRunning;
    [self showHUDWithText:@"Timer started!"];
}

- (IBAction)interruptTimer:(id)sender
{
    self.timerState = TSReady;
}

- (NSTimeInterval)timeInterval
{
    return 25 * 60; // 25 minutes
}

- (void)showHUDWithText:(NSString *)text
{
    [hudLabel setStringValue:text];
    
    NSViewAnimation *a = [[[NSViewAnimation alloc] initWithDuration:0.2 animationCurve:NSAnimationLinear] autorelease];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:hudWindow forKey:NSViewAnimationTargetKey];
    [dict setValue:NSViewAnimationFadeInEffect forKey:NSViewAnimationEffectKey];
    [a setViewAnimations:[NSArray arrayWithObject:dict]];
    [a startAnimation];
    [self performSelector:@selector(hideHUD) withObject:nil afterDelay:2.5];
}

- (void)hideHUD
{
    NSViewAnimation *a = [[[NSViewAnimation alloc] initWithDuration:0.7 animationCurve:NSAnimationLinear] autorelease];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:hudWindow forKey:NSViewAnimationTargetKey];
    [dict setValue:NSViewAnimationFadeOutEffect forKey:NSViewAnimationEffectKey];
    [a setViewAnimations:[NSArray arrayWithObject:dict]];
    [a startAnimation];
}

- (void)dealloc
{
    [statusItem release];
    [endDate release];
    [super dealloc];
}

@end
