#import "PWPrefURLInstallation.h"
#import "PWPrefURLInstallationRootController.h"

extern NSBundle *bundle;

@implementation PWPrefURLInstallation

- (instancetype)initWithURL:(NSURL *)url type:(PWPrefURLInstallationType)type fromPreference:(BOOL)fromPreference {
	
	PWPrefURLInstallationRootController *rootController = [[[PWPrefURLInstallationRootController alloc] initWithURL:url type:type fromPreference:fromPreference] autorelease];
	
	self = [super initWithRootViewController:rootController];
	return self;
}

@end