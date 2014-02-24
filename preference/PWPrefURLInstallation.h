#import "header.h"

@interface PWPrefURLInstallation : UINavigationController

- (instancetype)initWithURL:(NSURL *)url type:(PWPrefURLInstallationType)type fromPreference:(BOOL)fromPreference;

@end