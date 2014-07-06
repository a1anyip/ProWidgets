#import "../header.h"
#import "interface.h"

#import <UIKit/UIKit.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

#define PTEXT(x) ([bundle localizedStringForKey:x value:nil table:nil])
#define IMAGE(x) ([UIImage imageNamed:x inBundle:bundle])
#define OPEN_URL(x) ([[UIApplication sharedApplication] openURL:[NSURL URLWithString:x]])

extern CGFloat tableViewInset;

#define TABLEVIEW_INSET tableViewInset
#define TABLEVIEW_INSETS UIEdgeInsetsMake(0.0, TABLEVIEW_INSET, 0.0, TABLEVIEW_INSET)
#define CONFIGURE_TABLEVIEW_INSET(tableView) [tableView _setSectionContentInset:TABLEVIEW_INSETS];

@class PWPrefController, PWPrefView, PWPrefInfoView;
@class PWPrefWidgets, PWPrefWidgetsView, PWPrefWidgetPreference;
@class PWPrefThemes, PWPrefThemesView;
@class PWPrefActivation, PWPrefActivationView, PWPrefActivationPreference;
@class PWPrefConfiguration;
@class PWPrefPageViewController, PWPrefListController;
@class PWPrefURLInstallation, PWPrefURLInstallationRootController, PWPrefURLInstallationRootView;

typedef enum {
	PWPrefURLInstallationTypeNone,
	PWPrefURLInstallationTypeWidget,
	PWPrefURLInstallationTypeTheme
} PWPrefURLInstallationType;