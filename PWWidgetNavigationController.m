//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWWidgetNavigationController.h"
#import "PWContentViewController.h"

@implementation PWWidgetNavigationController

// ignore the height of status bar
- (CGFloat)_statusBarHeightAdjustmentForCurrentOrientation {
	return 0.0;
}

- (void)setViewControllers:(NSArray *)viewControllers {
	[self setViewControllers:viewControllers animated:YES];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
	
	[self.topViewController.view endEditing:YES];
	
	for (UIViewController *viewController in viewControllers) {
		if (![viewController isKindOfClass:[PWContentViewController class]]) {
			LOG(@"PWWidgetNavigationController: Unable to set view controllers. Reason: one of the view controllers (%@) is not a subclass of PWContentViewController.", viewController);
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
	
	[self.topViewController.view endEditing:YES];
	
	if (![viewController isKindOfClass:[PWContentViewController class]] &&
		![viewController isKindOfClass:objc_getClass("TKToneClassicsTableViewController")]) {
		
		LOG(@"PWWidgetNavigationController: Unable to push view controller (%@). Reason: view controller is not a subclass of PWContentViewController.", viewController);
		
		return;
	}
	
	if (self.topViewController == nil) animated = NO;
	[super pushViewController:viewController animated:animated];
}

- (void)popViewController {
	[self popViewControllerAnimated:YES];
}

- (void)popViewControllerAnimated:(BOOL)animated {
	[self.topViewController.view endEditing:YES];
	[super popViewControllerAnimated:animated];
}

@end