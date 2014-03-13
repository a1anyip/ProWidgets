@interface AppController : UIApplication

- (void)_selectViewController:(id)viewController;

@end

@interface ClockManager : NSObject

+ (instancetype)sharedManager;
+ (void)loadUserPreferences;
+ (void)saveAndNotifyForUserPreferences:(BOOL)arg1 localNotifications:(BOOL)arg2;
- (void)refreshScheduledLocalNotificationsCache;

@end

@interface TimerManager : NSObject

@property(readonly, nonatomic) int state;
@property(readonly, readonly) NSTimeInterval fireTime;
@property(readonly, readonly) NSTimeInterval remainingTime;
@property(nonatomic, copy) NSString *defaultSound;

+ (instancetype)sharedManager;

- (void)changeSound:(NSString *)sound;
- (BOOL)resume;
- (BOOL)pause;
- (BOOL)cancel;
- (void)scheduleAt:(CGFloat)time withSound:(NSString *)sound;
- (void)reloadState;

@end

@interface TimerViewController : UIViewController

@end