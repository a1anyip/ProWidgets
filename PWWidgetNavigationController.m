//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWWidgetNavigationController.h"
#import "PWContentViewControllerDelegate.h"

@implementation PWWidgetNavigationController

// ignore the height of status bar
- (CGFloat)_statusBarHeightAdjustmentForCurrentOrientation {
	return 0.0;
}

- (void)setViewControllers:(NSArray *)viewControllers {
	[self setViewControllers:viewControllers animated:YES];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
	
	for (UIViewController *viewController in viewControllers) {
		if (![viewController.class conformsToProtocol:@protocol(PWContentViewControllerDelegate)]) {
			LOG(@"PWWidgetNavigationController: Unable to set view controllers. Reason: one of the view controllers (%@) does not conform to PWContentViewControllerDelegate protocol.", viewController);
			return;
		}
	}
	
	if (self.topViewController == nil) animated = NO;
	
	if (animated) {
		applyFadeTransition(self.view, .2);
	}
	
	[super setViewControllers:viewControllers animated:NO];
}

- (void)pushViewController:(UIViewController *)viewController {
	[self pushViewController:viewController animated:YES];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
	
	if (![viewController.class conformsToProtocol:@protocol(PWContentViewControllerDelegate)]) {
		LOG(@"PWWidgetNavigationController: Unable to push view controller (%@). Reason: view controller does not conform to PWContentViewControllerDelegate protocol.", viewController);
		return;
	}
	
	if (self.topViewController == nil) animated = NO;
	[super pushViewController:viewController animated:animated];
}

- (void)popViewController {
	[self popViewControllerAnimated:YES];
}

- (void)popViewControllerAnimated:(BOOL)animated {
	[super popViewControllerAnimated:animated];
}

@end