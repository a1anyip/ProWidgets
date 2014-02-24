#import "header.h"
#import "PWPrefPageViewController.h"

@interface PWPrefThemes : PWPrefPageViewController<UITableViewDataSource, UITableViewDelegate> {
	
	NSString *_defaultThemeName;
	NSMutableArray *_installedThemes;
}

@property(nonatomic, copy) NSString *defaultThemeName;

- (void)reloadInstalledThemes;

@end