#import "header.h"
#import "PWPrefPageViewController.h"

@interface PWPrefThemes : PWPrefPageViewController<UITableViewDataSource, UITableViewDelegate> {
	
	NSString *_defaultThemeName;
	NSMutableArray *_installedThemes;
}

@property(nonatomic, copy) NSString *defaultThemeName;

- (void)reloadInstalledThemes;

- (void)_cellImageViewTapHandler:(UITapGestureRecognizer *)sender;
- (void)_infoViewConfirmButtonHandler:(NSDictionary *)info;
- (void)_uninstallThemeAtIndex:(NSUInteger)index;

@end