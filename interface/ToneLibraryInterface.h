@class TLToneManager, TLITunesTone;

@interface TLToneManager : NSObject

+ (instancetype)sharedRingtoneManager;
- (NSString *)defaultAlarmToneIdentifier;
- (NSString *)copyNameOfIdentifier:(NSString *)identifier isValid:(BOOL *)isValid;
- (NSString *)copyNameOfRingtoneWithIdentifier:(NSString *)identifier;
- (NSString *)localizedNameWithIdentifier:(NSString *)identifier;

- (void)setDelegate:(id)delegate;

@end

@interface TLITunesTone : NSObject

@property(nonatomic, copy) NSString *name;

@end