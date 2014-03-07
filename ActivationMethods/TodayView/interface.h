@class SBNotificationCenterController;
@class SBTodayWidgetAndTomorrowSectionHeaderView, SBBulletinViewController, SBBBSectionInfo;

@interface SBNotificationCenterController : NSObject

+ (id)sharedInstance;
- (void)dismissAnimated:(BOOL)animated;

@end

@interface SBTodayWidgetAndTomorrowSectionHeaderView : UITableViewHeaderFooterView

- (UITableView *)tableView;
- (void)updateVisibility;
- (void)_pw_pressed;

@end

@interface SBBulletinViewController : UIViewController

@end

@interface SBBBSectionInfo : NSObject

- (NSString *)identifier;

@end

@interface UITableView ()

- (NSInteger)_sectionForHeaderView:(id)headerView;

@end