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
		_backgroundView = [PWBackgroundView new];
		//_backgroundView.backgroundColor = [UIColor blackColor];
		//_backgroundView.alpha = .4;
		_backgroundView.userInteractionEnabled = NO;
		[self addSubview:_backgroundView];
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	_backgroundView.frame = self.bounds;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	
	UIView *result = [super hitTest:point withEvent:event];
	
	if ([result isKindOfClass:[PWMiniView class]]) {
		return result;
	}
	
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

- (void)updateBackgroundViewRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius animated:(BOOL)animated {
	CGFloat extraSize = PWSheetMotionEffectDistance;
	_backgroundView.frame = CGRectInset(self.bounds, -extraSize, -extraSize);
	[_backgroundView setMaskRect:rect cornerRadius:cornerRadius animated:animated];
}

@end