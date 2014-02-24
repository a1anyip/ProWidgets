#import "../header.h"
#import "interface.h"

#import <UIKit/UIKit.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

#define IMAGE(x) ([UIImage imageNamed:x inBundle:bundle])
#define OPEN_URL(x) ([[UIApplication sharedApplication] openURL:[NSURL URLWithString:x]])

@class PWPrefController, PWPrefView;
@class PWPrefWidgets, PWPrefWidgetsView, PWPrefWidgetPreference;
@class PWPrefThemes, PWPrefThemesView;
@class PWPrefActivation, PWPrefActivationView, PWPrefActivationPreference;
@class PWPrefConfiguration;
@class PWPrefPageViewController, PWPrefListController;
@class PWPrefURLInstallation, PWPrefURLInstallationRootController, PWPrefURLInstallationRootView, PWPrefURLInstallationInfoView;

typedef enum {
	PWPrefURLInstallationTypeNone,
	PWPrefURLInstallationTypeWidget,
	PWPrefURLInstallationTypeTheme
} PWPrefURLInstallationType;