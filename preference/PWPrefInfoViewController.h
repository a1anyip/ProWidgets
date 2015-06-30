#import "header.h"
#import "PWPrefInfoView.h"

@class PWPrefInfoViewInnerController;

@interface PWPrefInfoViewController : UINavigationController {
	
	PWPrefInfoViewInnerController *_innerViewController;
}

- (PWPrefInfoView *)infoView;

@end

@interface PWPrefInfoViewInnerController : UIViewController

@end