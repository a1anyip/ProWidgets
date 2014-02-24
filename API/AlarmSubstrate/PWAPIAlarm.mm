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

%hook AppController

// to prevent MobileTimer app from terminating itself
- (UIApplicationState)applicationState {
	return UIApplicationStateActive;
}

%end

static inline __attribute__((constructor)) void init() {
	@autoreleasepool {
		
		%init;
		
		[OBJCIPC registerIncomingMessageFromSpringBoardHandlerForMessageName:@"PWAPIAlarm" handler:^NSDictionary *(NSDictionary *dict) {
			
			if (![UIApplication sharedApplication].protectedDataAvailable) {
				LOG(@"Protected data is not available.");
				return nil;
			}
			
			AlarmManager *manager = [objc_getClass("AlarmManager") sharedManager];
			NSString *action = dict[@"action"];
			NSString *alarmId = dict[@"alarmId"];
			
			// retrieve alarm view controller
			AlarmViewController *alarmViewController = MSHookIvar<AlarmViewController *>([UIApplication sharedApplication], "_alarmViewController");
			
			LOG(@"PWAPIAlarm: Received action (%@)", action);
			
			if ([action isEqualToString:@"getActiveState"]) {
				
				Alarm *alarm = [manager alarmWithId:alarmId];
				if (alarm == nil) return nil;
				
				BOOL active = alarm.active;
				return @{ @"active": @(active) };
				
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
				
				// notify view controller to add the alarm and update its table view
				[alarmViewController didEditAlarm:alarm];
				
				// update its active state
				if (!active) {
					[alarmViewController activeChangedForAlarm:alarm active:NO];
				}
				
				// write to preference file
				[AlarmManager writeAlarmsToPreferences:manager.alarms];
				CFPreferencesSynchronize(CFSTR("com.apple.mobiletimer"), kCFPreferencesAnyUser, kCFPreferencesAnyHost);
				
				// to force the view controller to update its UI
				[alarmViewController viewWillAppear:YES];
				
				// retrieve the alarm id
				NSString *alarmId = alarm.alarmId;
				
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
				
				// write to preference file
				[AlarmManager writeAlarmsToPreferences:manager.alarms];
				CFPreferencesSynchronize(CFSTR("com.apple.mobiletimer"), kCFPreferencesAnyUser, kCFPreferencesAnyHost);
				
				// to force the view controller to update its UI
				[alarmViewController viewWillAppear:YES];
				
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
					
					[alarmViewController activeChangedForAlarm:alarm active:[numberValue boolValue]];
					[alarmViewController viewWillAppear:YES];
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
				
				// notify view controller to add the alarm and update its table view
				[alarmViewController didEditAlarm:alarm];
				
				// write to preference file
				[AlarmManager writeAlarmsToPreferences:manager.alarms];
				CFPreferencesSynchronize(CFSTR("com.apple.mobiletimer"), kCFPreferencesAnyUser, kCFPreferencesAnyHost);
				
				// to force the view controller to update its UI
				[alarmViewController viewWillAppear:YES];
				
			} else if ([action isEqualToString:@"setDefaultSound"]) {
				
				NSString *identifier = dict[@"identifier"];
				NSUInteger type = [dict[@"type"] unsignedIntegerValue];
				
				[manager setDefaultSound:identifier ofType:type];
				CFPreferencesSynchronize(CFSTR("com.apple.mobiletimer"), kCFPreferencesAnyUser, kCFPreferencesAnyHost);
			}
			
			return nil;
		}];
		
	}
}