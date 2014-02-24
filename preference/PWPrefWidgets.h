#import "header.h"
#import "PWPrefPageViewController.h"

@interface PWPrefWidgets : PWPrefPageViewController<UITableViewDataSource, UITableViewDelegate> {
	
	NSMutableArray *_installedWidgets;
}

- (void)reloadInstalledWidgets;

@end