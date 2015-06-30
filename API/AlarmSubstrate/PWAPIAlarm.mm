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
#define UI_UPDATE [alarmViewController viewWillAppear:YES];

%hook AppController

// to prevent MobileTimer app from terminating itself
- (UIApplicationState)applicationState {
	return UIApplicationStateActive;
}

%end

%hook ClockManager

- (void)scheduleLocalNotification:(id)notification {
	%orig;
	[OBJCIPC sendMessageToSpringBoardWithMessageName:@"PWAPIAlarm" dictionary:@{ @"notification": @"LocalNotificationChanged" } replyHandler:nil];
}

- (void)cancelLocalNotification:(id)notification {
	%orig;
	[OBJCIPC sendMessageToSpringBoardWithMessageName:@"PWAPIAlarm" dictionary:@{ @"notification": @"LocalNotificationChanged" } replyHandler:nil];
}

%end

static inline __attribute__((constructor)) void init() {
	@autoreleasepool {
		
		%init;
		
		[OBJCIPC registerIncomingMessageFromSpringBoardHandlerForMessageName:@"PWAPIAlarm" handler:^NSDictionary *(NSDictionary *dict) {
			
			[objc_getClass("ClockManager") loadUserPreferences];
			ClockManager *clockManager = [objc_getClass("ClockManager") sharedManager];
			[clockManager refreshScheduledLocalNotificationsCache];
			
			AlarmManager *manager = [objc_getClass("AlarmManager") sharedManager];
			[manager loadAlarms];
			[manager loadScheduledNotifications];
			
			NSString *action = dict[@"action"];
			NSString *alarmId = dict[@"alarmId"];
			
			// retrieve alarm view controller
			AppController *app = (AppController *)[UIApplication sharedApplication];
			AlarmViewController *alarmViewController = MSHookIvar<AlarmViewController *>(app, "_alarmViewController");
			
			LOG(@"PWAPIAlarm: Received action (%@)", action);
			
			if ([action isEqualToString:@"getActiveState"]) {
				
				Alarm *alarm = [manager alarmWithId:alarmId];
				if (alarm == nil) return nil;
				
				BOOL active = alarm.active;
				return @{ @"active": @(active) };
				
			} else if ([action isEqualToString:@"getActiveStates"]) {
				
				NSMutableDictionary *states = [NSMutableDictionary dictionary];
				NSArray *alarms = [manager alarms];
				
				for (Alarm *alarm in alarms) {
					NSString *alarmId = alarm.alarmId;
					if (alarmId == nil) continue;
					BOOL active = alarm.active;
					[states setObject:@(active) forKey:alarmId];
				}
				
				return states;
				
			} else if ([action isEqualToString:@"add"]) {
				
				NSString *title = dict[@"title"];
				BOOL active = [dict[@"active"] boolValue];
				NSUInteger hour = [dict[@"hour"] unsignedIntegerValue];
				NSUInteger minute = [dict[@"minute"] unsignedIntegerValue];
				BOOL allowsSnooze = [dict[@"allowsSnooze"] boolValue];
				NSUInteger daySetting = [dict[@"daySetting"] unsignedIntegerValue];
				NSString *sound = dict[@"sound"];
				NSInteger soundType = [dict[@"soundType"] integerValue];
				
				// verify hour and minute
				if (hour > 23) hour = 23;
				if (minute > 59) minute = 59;
				
				// veirfy day setting
				BOOL daySettingIsValid = [Alarm verifyDaySetting:@(daySetting) withMessageList:nil];
				if (!daySettingIsValid) daySetting = 0; // clear day setting
				
				// verify sound and sound type
				if ([sound length] == 0 || (soundType != AlarmSoundTypeRingtone && soundType != AlarmSoundTypeSong)) {
					// set default sound
					sound = manager.defaultSound;
					soundType = manager.defaultSoundType;
				};
				
				// construct a new alarm
				Alarm *alarm = [[Alarm alloc] initWithDefaultValues];
				
				// retrieve its editing proxy
				[alarm prepareEditingProxy];
				Alarm *editingProxy = alarm.editingProxy;
				
				// configure the editing proxy
				[editingProxy setTitle:title];
				editingProxy.hour = hour;
				editingProxy.minute = minute;
				editingProxy.allowsSnooze = allowsSnooze;
				editingProxy.daySetting = daySetting;
				[editingProxy setSound:sound ofType:soundType];
				
				// set the alarm
				[alarm applyChangesFromEditingProxy];
				
				// download the song
				if (alarm.soundType == AlarmSoundTypeSong) {
					// song needs to be downloaded before being assigned to an alarm
					[manager handleAlarm:alarm startedUsingSong:alarm.sound];
				}
				
				[manager addAlarm:alarm active:active];
				CLOCKMANAGER_UPDATE;
				UI_UPDATE;
				
				// retrieve the alarm id
				NSString *alarmId = [[alarm.alarmId copy] autorelease];
				
				// release the alarm instance
				[alarm release];
				
				if (alarmId != nil) {
					return @{ @"alarmId": alarmId };
				} else {
					return nil;
				}
			
			} else if ([action isEqualToString:@"remove"]) {
				
				Alarm *alarm = [manager alarmWithId:alarmId];
				if (alarm == nil) return nil;
				
				// remove the alarm
				[manager removeAlarm:alarm];
				CLOCKMANAGER_UPDATE;
				UI_UPDATE;
				
			} else if ([action isEqualToString:@"update"]) {
				
				NSString *alarmId = dict[@"alarmId"];
				NSString *key = dict[@"key"];
				id value = dict[@"value"];
				
				NSNumber *numberValue = (NSNumber *)value;
				NSDictionary *dictValue = (NSDictionary *)value;
				
				Alarm *alarm = [manager alarmWithId:alarmId];
				if (alarm == nil) return nil;
				
				// retrieve its editing proxy
				[alarm prepareEditingProxy];
				Alarm *editingProxy = alarm.editingProxy;
				
				if ([key isEqualToString:@"active"]) {
					
					[manager setAlarm:alarm active:[numberValue boolValue]];
					CLOCKMANAGER_UPDATE;
					UI_UPDATE;
					
					return nil;
					
				} else if ([key isEqualToString:@"title"]) {
					
					[editingProxy setTitle:(NSString *)value];
					
				} else if ([key isEqualToString:@"hour"]) {
					
					editingProxy.hour = [numberValue unsignedIntegerValue];
					
				} else if ([key isEqualToString:@"minute"]) {
					
					editingProxy.minute = [numberValue unsignedIntegerValue];
					
				} else if ([key isEqualToString:@"daySetting"]) {
					
					editingProxy.daySetting = [numberValue unsignedIntegerValue];
					
				} else if ([key isEqualToString:@"allowsSnooze"]) {
					
					editingProxy.allowsSnooze = [numberValue boolValue];
					
				} else if ([key isEqualToString:@"sound"]) {
					
					NSString *sound = dictValue[@"sound"];
					NSInteger soundType = [(NSNumber *)dictValue[@"soundType"] integerValue];
					[editingProxy setSound:sound ofType:soundType];
				}
				
				// set the alarm
				[alarm applyChangesFromEditingProxy];
				
				// download the song
				if ([key isEqualToString:@"sound"] && alarm.soundType == AlarmSoundTypeSong) {
					// song needs to be downloaded before being assigned to an alarm
					[manager handleAlarm:alarm startedUsingSong:alarm.sound];
				}
				
				[manager updateAlarm:alarm active:alarm.active];
				CLOCKMANAGER_UPDATE;
				UI_UPDATE;
				
			} else if ([action isEqualToString:@"setDefaultSound"]) {
				
				NSString *identifier = dict[@"identifier"];
				NSUInteger type = [dict[@"type"] unsignedIntegerValue];
				
				[manager setDefaultSound:identifier ofType:type];
				CLOCKMANAGER_UPDATE;
			}
			
			return nil;
		}];
		
	}
}