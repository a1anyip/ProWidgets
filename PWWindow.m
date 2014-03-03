//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWWindow.h"
#import "PWView.h"

@implementation PWWindow

- (instancetype)init {
	if (self = [super init]) {
		// Window Level
		// (Cut/Copy) UITextEffectsWindow	2100
		// (Undo/Cancel) ~Alert window		1996
		self.windowLevel = 1995;
		self.backgroundColor = [UIColor clearColor];
		self.userInteractionEnabled = YES;
		self.frame = [[UIScreen mainScreen] bounds];
	}
	return self;
}

- (void)adjustLayout {
	
	PWView *mainView = [PWController sharedInstance].mainView;
	
	UIInterfaceOrientation orientation = [[PWController sharedInstance] currentInterfaceOrientation];
	CGAffineTransform transform = [self orientationToTransform:orientation];
	
	mainView.transform = CGAffineTransformIdentity;
	mainView.transform = transform;
	
	// main view should always fill this window
	mainView.frame = self.bounds;
	[mainView layoutIfNeeded];
}

// simply show the window and make it key
- (void)show {
	[self adjustLayout];
	self.hidden = NO;
	[self makeKeyAndVisible];
}

// simply hide the window
- (void)hide {
	[self resignKeyWindow];
	self.hidden = YES;
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