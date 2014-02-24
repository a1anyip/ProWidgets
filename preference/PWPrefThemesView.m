#import "PWPrefThemesView.h"

extern NSBundle *bundle;

@implementation PWPrefThemesView

- (instancetype)init {
	if ((self = [super initWithFrame:CGRectZero style:UITableViewStyleGrouped])) {
		
	}
	return self;
}

- (void)dealloc {
	self.delegate = nil;
	self.dataSource = nil;
	[super dealloc];
}

@end