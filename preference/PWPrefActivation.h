#import "header.h"
#import "PWPrefPageViewController.h"

@interface PWPrefActivation : PWPrefPageViewController<UITableViewDataSource, UITableViewDelegate> {
	
	NSArray *_activationMethods;
	NSMutableArray *_visibleWidgets;
	NSMutableArray *_hiddenWidgets;
}

- (void)reloadActivationMethods;
- (void)reloadEnabledWidgets;

@end