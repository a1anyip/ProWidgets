//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWView.h"
#import "PWWindow.h"
#import "PWBackgroundView.h"
#import "PWTheme.h"
#import "PWController.h"
#import "PWWidgetController.h"
#import "PWWidget.h"
#import "PWMiniView.h"
#import "PWWidgetController.h"

@implementation PWView

- (instancetype)init {
	if (self = [super init]) {
		
		self.userInteractionEnabled = YES;
		
		// create PWBackgroundView
		if ([PWController shouldShowBackgroundView]) {
			_backgroundView = [PWBackgroundView new];
			_backgroundView.userInteractionEnabled = YES;
			[self addSubview:_backgroundView];
		}
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	_backgroundView.frame = CGRectInset(self.bounds, -PWSheetMotionEffectDistance, -PWSheetMotionEffectDistance);
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	
	UIView *result = [super hitTest:point withEvent:event];
	
	// background view
	if (result == _backgroundView) {
		return result;
	}
	
	// mini view
	if ([result isKindOfClass:[PWMiniView class]]) {
		return result;
	}
	
	// container views
	NSSet *widgetControllers = [PWWidgetController allControllers];
	if ([widgetControllers count] > 0) {
		for (PWWidgetController *widgetController in widgetControllers) {
			if (widgetController.isPresented && !widgetController.isMinimized) {
				PWContainerView *containerView = widgetController.containerView;
				if ([result isDescendantOfView:containerView]) {
					return result;
				}
			}
		}
	}
	
	return nil;
}

@end