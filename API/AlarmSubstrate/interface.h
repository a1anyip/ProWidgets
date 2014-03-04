@class AlarmManager, Alarm;

// to convert bit mask for repeat days to readable string
extern NSString *DateMaskToString(int, BOOL, BOOL, BOOL);

typedef NS_ENUM(NSUInteger, AlarmSoundType) {
	AlarmSoundTypeRingtone = 1,
	AlarmSoundTypeSong = 2
};

typedef enum {
	AlarmDaySettingAlways	= 0,
	AlarmDaySettingMonday	= 1 << 0,
	AlarmDaySettingTuesday	= 1 << 1,
	AlarmDaySettingWednesday= 1 << 2,
	AlarmDaySettingThursday	= 1 << 3,
	AlarmDaySettingFriday	= 1 << 4,
	AlarmDaySettingSaturday	= 1 << 5,
	AlarmDaySettingSunday	= 1 << 6
} AlarmDaySetting;

@interface AppController : UIApplication

- (void)_selectViewController:(id)viewController;

@end

@interface ClockManager : NSObject

+ (instancetype)sharedManager;
+ (void)loadUserPreferences;
+ (void)saveAndNotifyForUserPreferences:(BOOL)arg1 localNotifications:(BOOL)arg2;
- (void)refreshScheduledLocalNotificationsCache;

@end

@interface AlarmManager : NSObject

@property(readonly, nonatomic) int defaultSoundType;
@property(readonly, nonatomic) NSString *defaultSound;

+ (NSArray *)copyReadAlarmsFromPreferences;
+ (void)writeAlarmsToPreferences:(NSArray *)alarms;
+ (instancetype)sharedManager;

- (void)unloadAlarms;
- (void)loadAlarms;
- (void)loadScheduledNotifications;

- (NSArray *)alarms;
- (Alarm *)alarmWithId:(NSString *)alarmId;
- (void)setAlarm:(Alarm *)alarm active:(BOOL)active;
- (void)updateAlarm:(Alarm *)alarm active:(BOOL)active;
- (void)addAlarm:(Alarm *)alarm active:(BOOL)active;
- (void)removeAlarm:(Alarm *)alarm;

- (void)setDefaultSound:(NSString *)identifier ofType:(NSUInteger)type;

- (void)handleAlarm:(Alarm *)alarm startedUsingSong:(NSString *)song;
- (void)handleAlarm:(Alarm *)alarm stoppedUsingSong:(NSString *)song;

@end

@interface Alarm : NSObject

@property(nonatomic, readonly) NSString *alarmId;
@property(nonatomic, readonly) NSString *uiTitle;
@property(nonatomic, getter=isActive, readonly) BOOL active;
@property(nonatomic) NSUInteger hour;
@property(nonatomic) NSUInteger minute;
@property(nonatomic) BOOL allowsSnooze;
@property(nonatomic, readonly) NSString *sound;
@property(nonatomic, readonly) int soundType;

@property(nonatomic) NSUInteger daySetting;
@property(nonatomic, retain) NSArray *repeatDays;
@property(nonatomic) BOOL repeats;

@property(nonatomic, readonly) NSMutableDictionary *settings;
@property(nonatomic, readonly) Alarm *editingProxy;

+(BOOL)verifyDaySetting:(NSNumber *)daySetting withMessageList:(id)list;

- (instancetype)initWithSettings:(NSDictionary *)settings;
- (instancetype)initWithDefaultValues;
- (void)prepareEditingProxy;
- (void)applyChangesFromEditingProxy;
- (void)markModified;
- (void)applySettings:(NSDictionary *)settings;
- (void)setTitle:(NSString *)title;
- (void)setSound:(NSString *)sound ofType:(int)type;

@end

@interface AlarmViewController : UIViewController

- (void)activeChangedForAlarm:(Alarm *)alarm active:(BOOL)active;
- (void)didEditAlarm:(Alarm *)alarm;

@end