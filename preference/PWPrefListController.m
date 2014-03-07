#import "PWPrefListController.h"

@implementation PWPrefListController

- (instancetype)initWithPlist:(NSString *)plist inBundle:(NSBundle *)bundle {
	if ((self = [super init])) {
		
		// in case the plist value contains the path extension
		if ([plist hasSuffix:@".plist"]) {
			plist = [plist stringByDeletingPathExtension];
		}
		
		self.plist = plist;
		self.bundle = bundle;
	}
	return self;
}

- (NSArray *)specifiers {
	if (_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:self.plist target:self] retain];
	}
	return _specifiers;
}

- (void)dealloc {
	[_plist release], _plist = nil;
	[_bundle release], _bundle = nil;
	[super dealloc];
}

@end