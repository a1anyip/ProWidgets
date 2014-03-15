//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "Alarm.h"
#import "../PWController.h"
#import "../JSBridge/PWJSBridgeWrapper.h"
#import <objcipc/objcipc.h>

#define TimerIdentifier @"com.apple.mobiletimer"

#define PW_IMP_DAYSETTING(day) - (NSUInteger)daySetting##day {\
	return AlarmDaySetting##day;\
}

#define PW_IMP_ALARM(name,setName,type) - (type)name {\
	return [self _alarmInstance].name;\
}\
\
- (void)set##setName:(type)value {\
	[self _updateAlarmValue:@(value) forKey:@#name];\
}

#define PW_IMP_ALARM_WRAPPER(name,setName,type,toType) - (JSValue *)name {\
	return [JSValue valueWith##toType:_alarm.name inContext:[JSContext currentContext]];\
}\
\
- (void)set##setName:(JSValue *)value {\
	_alarm.name = [value to##toType];\
}

@implementation PWAPIAlarmManagerWrapper

- (AlarmSoundType)alarmSoundTypeRingtone { return AlarmSoundTypeRingtone; }
- (AlarmSoundType)alarmSoundTypeSong { return AlarmSoundTypeSong; }

PW_IMP_DAYSETTING(Always)
PW_IMP_DAYSETTING(Monday)
PW_IMP_DAYSETTING(Tuesday)
PW_IMP_DAYSETTING(Wednesday)
PW_IMP_DAYSETTING(Thursday)
PW_IMP_DAYSETTING(Friday)
PW_IMP_DAYSETTING(Saturday)
PW_IMP_DAYSETTING(Sunday)

- (NSArray *)allAlarms {
	
	AlarmManager *manager = [PWAPIAlarmManager _alarmManager];
	NSArray *alarms = [[manager alarms] copy];
	
	NSMutableArray *result = [NSMutableArray array];
	for (Alarm *alarm in alarms) {
		PWAPIAlarm *object = [PWAPIAlarm alarmWithId:alarm.alarmId];
		PWAPIAlarmWrapper *wrapper = [PWAPIAlarmWrapper wrapperOfAlarm:object];
		if (wrapper != nil)
			[result addObject:wrapper];
	}
	
	[alarms release];

	return result;
}

- (PWAPIAlarmWrapper *)getById:(JSValue *)alarmId {
	
	if ([alarmId isUndefined]) {
		[_bridge throwException:@"getById: requires argument 1 (alarm ID)"];
		return nil;
	}
	
	NSString *_alarmId = [alarmId toString];
	PWAPIAlarm *alarm = [PWAPIAlarm alarmWithId:_alarmId];
	return [PWAPIAlarmWrapper wrapperOfAlarm:alarm];
}

- (PWAPIAlarmWrapper *)add:(JSValue *)title :(JSValue *)active :(JSValue *)hour :(JSValue *)minute :(JSValue *)daySetting :(JSValue *)allowsSnooze :(JSValue *)sound :(JSValue *)soundType {
	
	if ([title isUndefined] || [active isUndefined] || [hour isUndefined] || [minute isUndefined]) {
		[_bridge throwException:@"add: requires first 4 arguments (title, active, hour and minute)"];
		return nil;
	}
	
	NSString *_title = [title isNull] ? nil : [title toString];
	BOOL _active = [active toBool];
	NSUInteger _hour = [hour toUInt32];
	NSUInteger _minute = [minute toUInt32];
	NSUInteger _daySetting = [daySetting isUndefined] ? 0 : [daySetting toUInt32];
	BOOL _allowsSnooze = [allowsSnooze isUndefined] ? YES : [allowsSnooze toBool];
	NSString *_sound = [sound isUndefined] ? nil : [sound toString];
	AlarmSoundType _soundType = [PWAPIAlarmManager soundTypeFromInteger:[soundType toInt32]];
	
	PWAPIAlarm *alarm = [PWAPIAlarmManager addAlarmWithTitle:_title active:_active hour:_hour minute:_minute daySetting:_daySetting allowsSnooze:_allowsSnooze sound:_sound soundType:_soundType];
	return [PWAPIAlarmWrapper wrapperOfAlarm:alarm];
}

- (void)remove:(JSValue *)alarm {
	
	if ([alarm isUndefined]) {
		[_bridge throwException:@"remove: requires argument 1 (alarm ID or object)"];
		return;
	}
	
	PWAPIAlarmWrapper *wrapper = (PWAPIAlarmWrapper *)[alarm toObjectOfClass:[PWAPIAlarmWrapper class]];
	
	if (wrapper != nil) {
		[PWAPIAlarmManager removeAlarm:wrapper._alarm];
	} else {
		NSString *alarmId = [alarm toString];
		[PWAPIAlarmManager removeAlarmWithId:alarmId];
	}
}

- (void)setDefaultSound:(JSValue *)identifier :(JSValue *)type {
	
	if ([identifier isUndefined] || [type isUndefined]) {
		[_bridge throwException:@"setDefaultSound: requires first 2 arguments (sound identifier and type)"];
		return;
	}
	
	NSString *_identifier = [identifier isNull] ? @"" : [identifier toString];
	AlarmSoundType _type = [PWAPIAlarmManager soundTypeFromInteger:[type toUInt32]];
	
	[PWAPIAlarmManager setDefaultSound:_identifier ofType:_type];
}

- (void)dealloc {
	DEALLOCLOG;
	[super dealloc];
}

@end

@implementation PWAPIAlarmWrapper

+ (instancetype)wrapperOfAlarm:(PWAPIAlarm *)alarm {
	if (alarm == nil) return nil;
	PWAPIAlarmWrapper *wrapper = [self new];
	[wrapper _setAlarm:alarm];
	return [wrapper autorelease];
}

- (NSString *)alarmId {
	return _alarm.alarmId;
}

- (JSValue *)title {
	return [JSValue valueWithObject:_alarm.title inContext:_bridge.context];
}

- (void)setTitle:(JSValue *)value {
	_alarm.title = [value isUndefined] || [value isNull] ? nil : [value toString];
}

PW_IMP_ALARM_WRAPPER(active, Active, BOOL, Bool)
PW_IMP_ALARM_WRAPPER(hour, Hour, NSUInteger, UInt32)
PW_IMP_ALARM_WRAPPER(minute, Minute, NSUInteger, UInt32)
PW_IMP_ALARM_WRAPPER(allowsSnooze, AllowsSnooze, BOOL, Bool)
PW_IMP_ALARM_WRAPPER(daySetting, DaySetting, NSUInteger, UInt32)

- (NSString *)sound {
	return _alarm.sound;
}

- (AlarmSoundType)soundType {
	return _alarm.soundType;
}

- (void)setSound:(JSValue *)sound :(JSValue *)soundType {
	NSString *_sound = [sound isUndefined] ? nil : [sound toString];
	NSInteger _soundType = [soundType toInt32];
	[_alarm setSound:_sound ofType:_soundType];
}

- (PWAPIAlarm *)_alarm {
	return _alarm;
}

- (void)_setAlarm:(PWAPIAlarm *)alarm {
	if (_alarm != nil) return;
	_alarm = [alarm retain];
}

- (void)dealloc {
	DEALLOCLOG;
	RELEASE(_alarm)
	[super dealloc];
}

@end

static BOOL _clockPreferencesChanged = NO;
static NSDictionary *_alarmActiveStates = nil;
static NSDate *_alarmsLastModified = nil;

@implementation PWAPIAlarmManager

+ (void)load {
	
	CHECK_API();
	
	[OBJCIPC registerIncomingMessageHandlerForAppWithIdentifier:TimerIdentifier andMessageName:@"PWAPIAlarm" handler:^NSDictionary *(NSDictionary *dict) {
		NSString *notification = dict[@"notification"];
		if ([notification isEqualToString:@"LocalNotificationChanged"]) {
			LOG(@"PWAPIAlarmManager: Local notification changed");
			_clockPreferencesChanged = YES;
		}
		return nil;
	}];
}

+ (AlarmSoundType)soundTypeFromInteger:(NSUInteger)number {
	return number == 2 ? AlarmSoundTypeSong : AlarmSoundTypeRingtone;
}

+ (NSArray *)allAlarms {
	
	AlarmManager *manager = [self _alarmManager];
	NSArray *alarms = [[manager alarms] copy];
	
	NSMutableArray *result = [NSMutableArray array];
	for (Alarm *alarm in alarms) {
		PWAPIAlarm *object = [PWAPIAlarm alarmWithId:alarm.alarmId];
		[result addObject:object];
	}
	
	[alarms release];
	
	return result;
}

+ (PWAPIAlarm *)alarmWithId:(NSString *)alarmId {
	return [PWAPIAlarm alarmWithId:alarmId];
}

+ (PWAPIAlarm *)addAlarmWithTitle:(NSString *)title active:(BOOL)active hour:(NSUInteger)hour minute:(NSUInteger)minute daySetting:(NSUInteger)daySetting allowsSnooze:(BOOL)allowsSnooze sound:(NSString *)sound soundType:(AlarmSoundType)soundType {
	
	CHECK_API(nil);
	
	if (title == nil) {
		title = @"";
	}
	
	if (sound == nil) {
		sound = @"";
	}
	
	NSDictionary *dict = @{
						   @"action": @"add",
						   @"title": title,
						   @"active": @(active),
						   @"hour": @(hour),
						   @"minute": @(minute),
						   @"daySetting": @(daySetting),
						   @"allowsSnooze": @(allowsSnooze),
						   @"sound": sound,
						   @"soundType": @(soundType)
						   };
	
	// synchronized
	NSDictionary *reply = [OBJCIPC sendMessageToAppWithIdentifier:TimerIdentifier messageName:@"PWAPIAlarm" dictionary:dict];
	NSString *alarmId = reply[@"alarmId"];
	
	if (alarmId == nil)
		return nil;
	else
		return [PWAPIAlarm alarmWithId:alarmId];
}

+ (void)removeAlarmWithId:(NSString *)alarmId {
	
	CHECK_API();
	
	if (alarmId == nil) return;
	
	NSDictionary *dict = @{
						   @"action": @"remove",
						   @"alarmId": alarmId
						   };
	
	// synchronized
	[OBJCIPC sendMessageToAppWithIdentifier:TimerIdentifier messageName:@"PWAPIAlarm" dictionary:dict];
}

+ (void)removeAlarm:(PWAPIAlarm *)alarm {
	NSString *alarmId = alarm.alarmId;
	[self removeAlarmWithId:alarmId];
}

+ (NSString *)defaultSound {
	AlarmManager *manager = [self _alarmManager];
	if (manager == nil) return @"";
	return *(NSString **)instanceVar(manager, "_defaultSound");
}

+ (AlarmSoundType)defaultSoundType {
	AlarmManager *manager = [self _alarmManager];
	if (manager == nil) return AlarmSoundTypeRingtone;
	return (AlarmSoundType)(*(NSInteger *)instanceVar(manager, "_defaultSoundType"));
}

+ (void)setDefaultSound:(NSString *)identifier ofType:(AlarmSoundType)type {
	
	CHECK_API();
	
	if (identifier == nil) return;
	
	NSDictionary *dict = @{
						   @"action": @"setDefaultSound",
						   @"identifier": identifier,
						   @"type": @(type)
						   };
	
	// synchronized
	[OBJCIPC sendMessageToAppWithIdentifier:TimerIdentifier messageName:@"PWAPIAlarm" dictionary:dict];
}

+ (AlarmManager *)_alarmManager {
	
	CHECK_API(nil);
	
	// retrieve the alarm instance
	AlarmManager *manager = [AlarmManager sharedManager];
	
	if (manager == nil) return nil;
	
	// reload alarms
	NSDictionary *preference = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.apple.mobiletimer.plist"];
	
	// check last modified time
	NSDate *lastModified = preference[@"AlarmsLastModified"];
	if (lastModified == nil || _alarmsLastModified == nil || ![lastModified isEqual:_alarmsLastModified]) {
		
		LOG(@"Reloading alarms from preference file.");
		
		NSMutableArray *newAlarms = [NSMutableArray array];
		NSArray *alarms = preference[@"Alarms"];
		for (NSDictionary *alarm in alarms) {
			Alarm *object = [[Alarm alloc] initWithSettings:alarm];
			if (object != nil) {
				[newAlarms addObject:object];
			}
		}
		
		NSArray *oldAlarms = *(NSArray **)instanceVar(manager, "_alarms");
		if (oldAlarms != nil) {
			[oldAlarms release];
		}
		
		object_setInstanceVariable(manager, "_alarms", [newAlarms copy]);
		_alarmsLastModified = [lastModified retain];
	}
	
	// load LastPickedAlarmSound, LastPickedAlarmSoundType
	NSString *oldDefaultSound = *(NSString **)instanceVar(manager, "_defaultSound");
	NSString *defaultSound = preference[@"LastPickedAlarmSound"];
	
	if (![oldDefaultSound isEqualToString:defaultSound]) {
		
		AlarmSoundType defaultSoundType = [self soundTypeFromInteger:[preference[@"LastPickedAlarmSoundType"] unsignedIntegerValue]];
		
		if (defaultSound == nil) {
			TLToneManager *toneManager = [objc_getClass("TLToneManager") sharedRingtoneManager];
			defaultSound = [toneManager defaultAlarmToneIdentifier];
			defaultSoundType = AlarmSoundTypeRingtone;
		}
		
		if (oldDefaultSound != nil) {
			[oldDefaultSound release];
		}
		object_setInstanceVariable(manager, "_defaultSound", [defaultSound copy]);
		
		Ivar defaultSoundTypeIvar = class_getInstanceVariable(object_getClass(manager), "");
		if (defaultSoundTypeIvar) {
			NSInteger *defaultSoundTypePointer = (NSInteger *)((uint8_t *)(void *)manager + ivar_getOffset(defaultSoundTypeIvar));
			*defaultSoundTypePointer = defaultSoundType;
		}
		
		LOG(@"Updated default sound identifier to <%@>, sound type to <%d>", defaultSound, (int)defaultSoundType);
	}
	
	return manager;
}

+ (void)_updateAlarmActiveStates {
	
	CHECK_API();
	
	NSDictionary *dict = @{ @"action": @"getActiveStates" };
	NSDictionary *result = [OBJCIPC sendMessageToAppWithIdentifier:TimerIdentifier messageName:@"PWAPIAlarm" dictionary:dict];
	
	[_alarmActiveStates release];
	_alarmActiveStates = [result copy];
	
	_clockPreferencesChanged = NO;
}

@end

@implementation PWAPIAlarm

+ (instancetype)alarmWithId:(NSString *)alarmId {
	
	// to ensure this actually exists
	AlarmManager *manager = [PWAPIAlarmManager _alarmManager];
	Alarm *alarm = [manager alarmWithId:alarmId];
	if (alarm == nil) return nil; // the alarm with given ID does not exist
	
	PWAPIAlarm *object = [self new];
	[object _setAlarmId:alarmId];
	return [object autorelease];
}

- (NSString *)title {
	return [self _alarmInstance].uiTitle;
}

- (void)setTitle:(NSString *)title {
	if (title == nil) title = @"";
	[self _updateAlarmValue:title forKey:@"title"];
}

- (BOOL)active {
	
	if (_alarmActiveStates == nil || _clockPreferencesChanged) {
		[PWAPIAlarmManager _updateAlarmActiveStates];
	}
	
	if (_alarmId != nil) {
		NSNumber *state = _alarmActiveStates[_alarmId];
		return [state boolValue];
	} else {
		return NO;
	}
}

- (void)setActive:(BOOL)active {
	[self _updateAlarmValue:@(active) forKey:@"active"];
}

PW_IMP_ALARM(hour, Hour, NSUInteger)
PW_IMP_ALARM(minute, Minute, NSUInteger)
PW_IMP_ALARM(allowsSnooze, AllowsSnooze, BOOL)
PW_IMP_ALARM(daySetting, DaySetting, NSUInteger)

// sound
- (NSString *)sound {
	return [self _alarmInstance].sound;
}

- (AlarmSoundType)soundType {
	return [PWAPIAlarmManager soundTypeFromInteger:[self _alarmInstance].soundType];
}

- (void)setSound:(NSString *)sound ofType:(NSInteger)type {
	if (sound == nil) sound = @"";
	[self _updateAlarmValue:@{ @"sound":sound, @"type":@(type) } forKey:@"sound"];
}

- (NSString *)_alarmId {
	return _alarmId;
}

- (void)_setAlarmId:(NSString *)alarmId {
	if (_alarmId != nil) return; // only can change once
	_alarmId = [alarmId copy];
}

- (Alarm *)_alarmInstance {
	if (_alarmId == nil) return nil;
	return [[PWAPIAlarmManager _alarmManager] alarmWithId:_alarmId];
}

- (void)_updateAlarmValue:(id)value forKey:(NSString *)key {
	
	CHECK_API();
	
	if (_alarmId == nil || key == nil || value == nil) return;
	
	NSDictionary *dict = @{
						   @"action": @"update",
						   @"alarmId": _alarmId,
						   @"key": key,
						   @"value": value
						   };
	
	// notify MobileTimer to make the changes (synchronous)
	[OBJCIPC sendMessageToAppWithIdentifier:TimerIdentifier messageName:@"PWAPIAlarm" dictionary:dict];
}

- (void)dealloc {
	DEALLOCLOG;
	RELEASE(_alarmId)
	[super dealloc];
}

@end