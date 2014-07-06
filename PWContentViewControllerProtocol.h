//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"

@protocol PWContentViewControllerProtocol <NSObject>

@required
- (BOOL)shouldMaximizeContentHeight;
- (BOOL)requiresKeyboard;
- (NSString *)title;
- (CGFloat)contentWidthForOrientation:(PWWidgetOrientation)orientation;
- (CGFloat)contentHeightForOrientation:(PWWidgetOrientation)orientation;

@optional
- (void)willBePresentedInNavigationController:(UINavigationController *)navigationController;
- (void)configureFirstResponder;

@end