#import "PWPrefExperimentalSettings.h"

extern NSBundle *bundle;

@implementation PWPrefExperimentalSettings

- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"PWPrefExperimentalSettings" target:self] retain];
	}
	return _specifiers;
}

@end