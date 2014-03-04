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
#import "PWContainerView.h"
#import "PWView.h"
#import "PWMiniView.h"

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
	
	// main view should always fill this window
	mainView.frame = self.bounds;
	[mainView layoutIfNeeded];
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

- (PWMiniView *)createMiniViewWithSnapshot:(UIImage *)snapshot {
	
	if (_miniView != nil) {
		RELEASE_VIEW(_miniView);
	}
	
	PWContainerView *containerView = [PWController sharedInstance].containerView;
	CGRect rect = containerView.frame;
	
	_miniView = [[PWMiniView alloc] initWithSnapshot:snapshot];
	_miniView.clipsToBounds = YES;
	_miniView.frame = rect;
	
	// configure gesture recognizers
	UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
	[panRecognizer setMinimumNumberOfTouches:1];
	[panRecognizer setMaximumNumberOfTouches:1];
	[_miniView addGestureRecognizer:panRecognizer];
	[panRecognizer release];
	
	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
	[_miniView addGestureRecognizer:singleTap];
	[singleTap release];
	
	UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
	doubleTap.numberOfTapsRequired = 2;
	[_miniView addGestureRecognizer:doubleTap];
	[doubleTap release];
	
	[singleTap requireGestureRecognizerToFail:doubleTap];
	
	[self addSubview:_miniView];
	
	return _miniView;
}

- (void)removeMiniView {
	if (_miniView == nil) return;
	RELEASE_VIEW(_miniView)
}

- (CGPoint)getInitialPositionOfMiniView {
	
	if (_recordedLastPosition)
		return _lastPosition;
	
	PWContainerView *containerView = [PWController sharedInstance].containerView;
	CGSize size = containerView.bounds.size;
	CGFloat screenWidth = 320.0;
	CGFloat statusBarHeight = 20.0;
	CGFloat scaledWidth = size.width * PWMinimizationScale;
	CGFloat scaledHeight = size.height * PWMinimizationScale;
	CGFloat originX = screenWidth - scaledWidth * .5;
	CGFloat originY = statusBarHeight + scaledHeight * .5;
	return CGPointMake(originX, originY);
}

- (void)handlePan:(UIPanGestureRecognizer *)sender {
	
	LOG(@"handlePan: %@", sender);
	
	UIGestureRecognizerState state = [sender state];
	
	CGSize windowSize = self.frame.size;
	CGSize miniViewSize = _miniView.bounds.size;
	
	miniViewSize.width *= PWMinimizationScale;
	miniViewSize.height *= PWMinimizationScale;
	
	CGFloat midX = windowSize.width / 2;
	CGFloat minX = miniViewSize.width / 2;
	CGFloat maxX = windowSize.width - minX;
	CGFloat minY = miniViewSize.height / 2;
	CGFloat maxY = windowSize.height - minY;
	
	// limit the moving bounds
	CGPoint center = [sender translationInView:self];
	center.x = MAX(minX, MIN(_miniView.center.x + center.x, maxX));
	center.y = MAX(minY, MIN(_miniView.center.y + center.y, maxY));
	
	[sender setTranslation:CGPointZero inView:self];
	
	if (state == UIGestureRecognizerStateEnded) {
		
		if (center.x <= midX) {
			center.x = minX;
		} else {
			center.x = maxX;
		}
		
		[UIView animateWithDuration:.2 animations:^{
			_miniView.center = center;
		}];
		
	} else {
		[UIView animateWithDuration:.1 animations:^{
			_miniView.center = center;
		}];
	}
	
	_recordedLastPosition = YES;
	_lastPosition = center;
}

- (void)handleSingleTap:(UIPanGestureRecognizer *)sender {
	LOG(@"handleSingleTap: %@", sender);
	[[PWController sharedInstance] _maximizeWidget];
}

- (void)handleDoubleTap:(UIPanGestureRecognizer *)sender {
	LOG(@"handleDoubleTap: %@", sender);
	[[PWController sharedInstance] _dismissMinimizedWidget];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	
	BOOL presenting = [PWController sharedInstance].isPresenting;
	BOOL minimized = [PWController sharedInstance].isMinimized;
	UIView *result = [super hitTest:point withEvent:event];
	
	LOG(@"hitTest (p: %@ / m: %@) (%@)", presenting ? @"YES" : @"NO", minimized ? @"YES" : @"NO", result);
	
	if (!presenting) {
		return nil; // pass through
	} else if (minimized) {
		if (result != nil && [result isKindOfClass:[PWMiniView class]]) {
			return result;
		} else {
			return nil;
		}
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
	RELEASE_VIEW(_miniView)
	[super dealloc];
}

@end