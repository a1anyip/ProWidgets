#import "header.h"
#import "PWPrefPageViewController.h"

@interface PWPrefWidgets : PWPrefPageViewController<UITableViewDataSource, UITableViewDelegate> {
	
	NSMutableArray *_installedWidgets;
}

- (void)reloadInstalledWidgets;

- (void)_cellImageViewTapHandler:(UITapGestureRecognizer *)sender;
- (void)_infoViewConfirmButtonHandler:(NSDictionary *)info;
- (void)_uninstallWidgetAtIndex:(NSUInteger)index;

@end