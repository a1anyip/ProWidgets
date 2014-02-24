#import "PWPrefConfiguration.h"

extern NSBundle *bundle;

@implementation PWPrefConfiguration

- (instancetype)init {
	return [super initWithPlist:@"PWPrefConfiguration" inBundle:bundle];
}

- (void)respring {
	
}

@end