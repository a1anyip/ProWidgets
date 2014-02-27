#import "PWPrefConfiguration.h"

extern NSBundle *bundle;

@implementation PWPrefConfiguration

- (instancetype)init {
	return [super initWithPlist:@"PWPrefConfiguration" inBundle:bundle];
}

- (void)resetPreference {
	[[NSDictionary dictionary] writeToFile:PWPrefPath atomically:YES];
	CFNotificationCenterRef center = CFNotificationCenterGetDarwinNotifyCenter();
	CFNotificationCenterPostNotification(center, CFSTR("cc.tweak.prowidgets.preferencechanged"), NULL, NULL, true);
}

- (void)respring {
	
}

@end