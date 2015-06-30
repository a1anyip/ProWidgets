//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"

@interface PWWidgetNavigationController : UINavigationController

- (void)setViewControllers:(NSArray *)viewControllers;
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated;

- (void)pushViewController:(UIViewController *)viewController;
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;

- (void)popViewController;
- (void)popViewControllerAnimated:(BOOL)animated;

@end