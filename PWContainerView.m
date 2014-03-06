//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWContainerView.h"
#import "PWController.h"
#import "PWWidgetController.h"
#import "PWWidget.h"
#import "PWTheme.h"

@implementation PWContainerView

- (instancetype)initWithWidgetController:(PWWidgetController *)widgetController {
	if (self = [super init]) {
		
		_widgetController = widgetController;
		
		self.userInteractionEnabled = YES;
		self.backgroundColor = [UIColor clearColor];
		self.clipsToBounds = YES;
		
		// create sheet background view
		_containerBackgroundView = [UIImageView new];
		_containerBackgroundView.userInteractionEnabled = NO;
		[self addSubview:_containerBackgroundView];
		
		// create overlay view
		_overlayView = [UIView new];
		_overlayView.userInteractionEnabled = YES;
		_overlayView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:.3];
		_overlayView.alpha = 0.0;
		[self addSubview:_overlayView];
	}
	return self;
}

- (void)layoutSubviews {
	
	_containerBackgroundView.frame = self.bounds;
	[_containerBackgroundView layoutIfNeeded];
	
	_overlayView.frame = self.bounds;
	[self bringSubviewToFront:_overlayView];
	
	_navigationControllerView.frame = self.bounds;
	[_navigationControllerView layoutIfNeeded];
	
	PWTheme *theme = _widgetController.widget.theme;
	[theme adjustLayout];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	UIView *result = [super hitTest:point withEvent:event];
	if (result != nil) {
		[_widgetController makeActive:YES];
	}
	return result;
}

- (void)showOverlay {
	[UIView animateWithDuration:.1 animations:^{
		_overlayView.alpha = 1.0;
	}];
}

- (void)hideOverlay {
	[UIView animateWithDuration:.1 animations:^{
		_overlayView.alpha = 0.0;
	}];
}

- (void)dealloc {
	
	DEALLOCLOG;
	
	_widgetController = nil;
	RELEASE_VIEW(_containerBackgroundView)
	RELEASE_VIEW(_overlayView)
	[_navigationControllerView removeFromSuperview], _navigationControllerView = nil;
	
	[super dealloc];
}

@end