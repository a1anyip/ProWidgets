@interface SpringBoard (LaunchApp)

- (BOOL)isLocked;
- (BOOL)launchApplicationWithIdentifier:(NSString *)identifier suspended:(BOOL)suspended;

@end

@interface SBApplication : NSObject

- (NSString *)path;

@end

@interface SBApplicationController : NSObject

+ (instancetype)sharedInstance;
- (SBApplication *)applicationWithDisplayIdentifier:(NSString *)identifier;

@end