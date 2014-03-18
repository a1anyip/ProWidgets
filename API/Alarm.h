//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "../header.h"
#import "../JSBridge/PWJSBridgeWrapper.h"
#import "AlarmSubstrate/interface.h"

@protocol PWAPIAlarmManagerWrapperExport <JSExport>

@property(nonatomic, readonly) AlarmSoundType alarmSoundTypeRingtone;
@property(nonatomic, readonly) AlarmSoundType alarmSoundTypeSong;

@property(nonatomic, readonly) NSUInteger daySettingAlways;
@property(nonatomic, readonly) NSUInteger daySettingMonday;
@property(nonatomic, readonly) NSUInteger daySettingTuesday;
@property(nonatomic, readonly) NSUInteger daySettingWednesday;
@property(nonatomic, readonly) NSUInteger daySettingThursday;
@property(nonatomic, readonly) NSUInteger daySettingFriday;
@property(nonatomic, readonly) NSUInteger daySettingSaturday;
@property(nonatomic, readonly) NSUInteger daySettingSunday;

// retrieve alarm objects
- (NSArray *)allAlarms;
- (PWAPIAlarmWrapper *)getById:(JSValue *)alarmId;

// add a new alarm
- (PWAPIAlarmWrapper *)add:(JSValue *)title :(JSValue *)active :(JSValue *)hour :(JSValue *)minute :(JSValue *)daySetting :(JSValue *)allowsSnooze :(JSValue *)sound :(JSValue *)soundType;

// remove alarms
- (void)remove:(JSValue *)alarm;

// change default sound
- (void)setDefaultSound:(JSValue *)identifier :(JSValue *)type;

@end

@protocol PWAPIAlarmWrapperExport <JSExport>

@property(nonatomic, readonly) NSString *alarmId;
@property(nonatomic, retain) JSValue *title;
@property(nonatomic, retain) JSValue *active;
@property(nonatomic, retain) JSValue *hour;
@property(nonatomic, retain) JSValue *minute;
@property(nonatomic, retain) JSValue *daySetting;
@property(nonatomic, retain) JSValue *allowsSnooze;
@property(nonatomic, readonly) NSString *sound;
@property(nonatomic, readonly) AlarmSoundType soundType;

- (void)setSound:(JSValue *)sound :(JSValue *)soundType;

@end

@interface PWAPIAlarmManagerWrapper : PWJSBridgeWrapper<PWAPIAlarmManagerWrapperExport>
@end

@interface PWAPIAlarmWrapper : PWJSBridgeWrapper<PWAPIAlarmWrapperExport> {
	
	PWAPIAlarm *_alarm;
}

+ (instancetype)wrapperOfAlarm:(PWAPIAlarm *)alarm;

- (PWAPIAlarm *)_alarm;
- (void)_setAlarm:(PWAPIAlarm *)alarm;

@end

// This is the alarm manager
@interface PWAPIAlarmManager : NSObject

+ (AlarmSoundType)soundTypeFromInteger:(NSUInteger)number;

// retrieve alarm objects
+ (NSArray *)allAlarms;
+ (PWAPIAlarm *)alarmWithId:(NSString *)alarmId;

// add a new alarm
+ (PWAPIAlarm *)addAlarmWithTitle:(NSString *)title active:(BOOL)active hour:(NSUInteger)hour minute:(NSUInteger)minute daySetting:(NSUInteger)daySetting allowsSnooze:(BOOL)allowsSnooze sound:(NSString *)sound soundType:(AlarmSoundType)soundType;

// remove alarms
+ (void)removeAlarmWithId:(NSString *)alarmId;
+ (void)removeAlarm:(PWAPIAlarm *)alarm;

// default sound
+ (NSString *)defaultSound;
+ (AlarmSoundType)defaultSoundType;
+ (void)setDefaultSound:(NSString *)identifier ofType:(AlarmSoundType)type;

+ (AlarmManager *)_alarmManager;
+ (void)_retrieveDefaultSound:(NSString **)defaultSoundOut defaultSoundType:(AlarmSoundType *)defaultSoundTypeOut;
+ (void)_updateAlarmActiveStates;

@end

// This wraps the existing Alarm class to ensure that all
// changes are synchronized with the MobileTimer app
@interface PWAPIAlarm : NSObject {
	
	NSString *_alarmId;
}

@property(nonatomic, readonly) NSString *alarmId;
@property(nonatomic, copy) NSString *title;
@property(nonatomic) BOOL active;
@property(nonatomic) NSUInteger hour;
@property(nonatomic) NSUInteger minute;
@property(nonatomic) NSUInteger daySetting;
@property(nonatomic) BOOL allowsSnooze;
@property(nonatomic, readonly) NSString *sound;
@property(nonatomic, readonly) AlarmSoundType soundType;

+ (instancetype)alarmWithId:(NSString *)alarmId;
- (void)setSound:(NSString *)sound ofType:(NSInteger)type;

- (NSString *)_alarmId;
- (void)_setAlarmId:(NSString *)alarmId;

- (Alarm *)_alarmInstance;
- (void)_updateAlarmValue:(id)value forKey:(NSString *)key;

@end