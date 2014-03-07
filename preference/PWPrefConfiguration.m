#import "PWPrefConfiguration.h"

extern NSBundle *bundle;

@implementation PWPrefConfiguration

- (instancetype)init {
	return [super initWithPlist:@"PWPrefConfiguration" inBundle:bundle];
}

- (void)resetPreference {
	
	// write an empty dictionary to preference file
	[[NSDictionary dictionary] writeToFile:PWPrefPath atomically:YES];
	CFNotificationCenterRef center = CFNotificationCenterGetDarwinNotifyCenter();
	CFNotificationCenterPostNotification(center, CFSTR("cc.tweak.prowidgets.preferencechanged"), NULL, NULL, true);
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"ProWidgets" message:@"Preference file is reset." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}

- (void)respring {
	system("killall -9 backboardd");
}

@end