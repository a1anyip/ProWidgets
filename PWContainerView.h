//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"

@interface PWContainerView : UIView {
	
	PWWidgetController *_widgetController;
	
	CGFloat _keyboardHeight;
	UIImageView *_containerBackgroundView;
	UIView *_overlayView;
	UIView *_navigationControllerView;
}

@property(nonatomic) CGFloat keyboardHeight;
@property(nonatomic, readonly) UIImageView *containerBackgroundView;
@property(nonatomic, assign) UIView *navigationControllerView;

- (instancetype)initWithWidgetController:(PWWidgetController *)widgetController;

- (void)showOverlay;
- (void)hideOverlay;

@end