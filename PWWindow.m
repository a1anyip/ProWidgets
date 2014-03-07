//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWWindow.h"
#import "PWController.h"
#import "PWWidgetController.h"
#import "PWContainerView.h"
#import "PWView.h"
#import "PWMiniView.h"

@implementation PWWindow

- (instancetype)init {
	if (self = [super init]) {
		// Window Levels
		// (Cut/Copy) UITextEffectsWindow	2100
		// (Undo/Cancel) ~Alert window		1996
		// Notification Center				1056
		// Control Center					1056
		// Lock Alert Window				1050
		// UIWindowLevelStatusBar			1000
		self.windowLevel = 1055.0;
		self.backgroundColor = [UIColor clearColor];
		self.userInteractionEnabled = YES;
		self.frame = [[UIScreen mainScreen] bounds];
		self.hidden = NO;
	}
	return self;
}

- (void)adjustLayout {
	
	PWView *mainView = [PWController sharedInstance].mainView;
	
	UIInterfaceOrientation orientation = [[PWController sharedInstance] currentInterfaceOrientation];
	CGAffineTransform transform = [self orientationToTransform:orientation];
	
	mainView.transform = CGAffineTransformIdentity;
	mainView.transform = transform;
	mainView.frame = self.bounds;
	
	[mainView setNeedsLayout];
	[mainView layoutIfNeeded];
	
	[PWWidgetController adjustLayoutForAllControllers];
}

// simply show the window and make it key
- (void)show {
	[self adjustLayout];
	[self makeKeyAndVisible];
}

// simply hide the window
- (void)hide {
	[self resignKeyWindow];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	
	UIView *result = [super hitTest:point withEvent:event];
	if (result == self) {
		return nil;
	} else {
		return result;
	}
}

- (CGAffineTransform)orientationToTransform:(UIInterfaceOrientation)orientation {
	if (orientation == UIInterfaceOrientationLandscapeRight) {
		return CGAffineTransformMakeRotation(M_PI_2);
	} else if (orientation == UIInterfaceOrientationLandscapeLeft) {
		return CGAffineTransformMakeRotation(-M_PI_2);
	} else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
		return CGAffineTransformMakeRotation(M_PI);
	} else if (orientation == UIInterfaceOrientationPortrait) {
		return CGAffineTransformMakeRotation(0.0);
	}
	
	return CGAffineTransformIdentity;
}

- (void)dealloc {
	DEALLOCLOG;
	[super dealloc];
}

@end