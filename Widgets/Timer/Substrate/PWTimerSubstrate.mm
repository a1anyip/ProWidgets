//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"
#import "interface.h"
#import "substrate.h"
#import <objcipc/objcipc.h>

#define CLOCKMANAGER_UPDATE [objc_getClass("ClockManager") saveAndNotifyForUserPreferences:YES localNotifications:YES];
#define UI_UPDATE [timerViewController viewWillAppear:YES];

%hook AppController

// to prevent MobileTimer app from terminating itself
- (UIApplicationState)applicationState {
	return UIApplicationStateActive;
}

%end

%hook ClockManager

- (void)scheduleLocalNotification:(id)notification {
	%orig;
	[OBJCIPC sendMessageToSpringBoardWithMessageName:@"PWWidgetTimer" dictionary:@{ @"notification": @"LocalNotificationChanged" } replyHandler:nil];
}

- (void)cancelLocalNotification:(id)notification {
	%orig;
	[OBJCIPC sendMessageToSpringBoardWithMessageName:@"PWWidgetTimer" dictionary:@{ @"notification": @"LocalNotificationChanged" } replyHandler:nil];
}

%end

static inline __attribute__((constructor)) void init() {
	@autoreleasepool {
		
		%init;
		
		[OBJCIPC registerIncomingMessageFromSpringBoardHandlerForMessageName:@"PWWidgetTimer" handler:^NSDictionary *(NSDictionary *dict) {
			
			[objc_getClass("ClockManager") loadUserPreferences];
			ClockManager *clockManager = [objc_getClass("ClockManager") sharedManager];
			[clockManager refreshScheduledLocalNotificationsCache];
			
			TimerManager *manager = [objc_getClass("TimerManager") sharedManager];
			[manager reloadState];
			
			NSString *action = dict[@"action"];
			
			// retrieve alarm view controller
			AppController *app = (AppController *)[UIApplication sharedApplication];
			TimerViewController *timerViewController = MSHookIvar<TimerViewController *>(app, "_timerViewController");
			
			LOG(@"PWTimerSubstrate: Received action (%@)", action);
			
			if ([action isEqualToString:@"query"]) {
				
				NSString *subaction = dict[@"subaction"];
				
				if ([subaction isEqualToString:@"pause"]) {
					[manager pause];
					CLOCKMANAGER_UPDATE;
					UI_UPDATE;
				} else if ([subaction isEqualToString:@"resume"]) {
					[manager resume];
					CLOCKMANAGER_UPDATE;
					UI_UPDATE;
				}
				
				NSInteger state = manager.state;
				NSTimeInterval fireTime = manager.fireTime;
				NSTimeInterval remainingTime = manager.remainingTime;
				
				return @{ @"state": @(state), @"fireTime": @(fireTime), @"remainingTime": @(remainingTime) };
				
			} else if ([action isEqualToString:@"cancel"]) {
				
				[manager cancel];
				CLOCKMANAGER_UPDATE;
				UI_UPDATE;
				return nil;
				
			} else if ([action isEqualToString:@"changeSound"]) {
				
				NSString *sound = dict[@"sound"];
				[manager changeSound:sound];
				CLOCKMANAGER_UPDATE;
				UI_UPDATE;
				return nil;
				
			} else if ([action isEqualToString:@"schedule"]) {
				
				NSTimeInterval duration = [dict[@"duration"] doubleValue];
				NSString *sound = dict[@"sound"];
				
				if (sound == nil) {
					sound = [manager defaultSound];
				}
				
				// schedule the timer
				NSTimeInterval referenceTime = [NSDate timeIntervalSinceReferenceDate];
				[manager scheduleAt:referenceTime + duration withSound:sound];
				CLOCKMANAGER_UPDATE;
				UI_UPDATE;
				
				NSInteger state = manager.state;
				NSTimeInterval fireTime = manager.fireTime;
				
				return @{ @"state": @(state), @"fireTime": @(fireTime) };
			
			} else if ([action isEqualToString:@"setDefaultSound"]) {
				
				NSString *sound = dict[@"sound"];
				[manager setDefaultSound:sound];
				CLOCKMANAGER_UPDATE;
				UI_UPDATE;
				return nil;
			}
			
			return nil;
		}];
		
	}
}