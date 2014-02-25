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
#import "PWWidget.h"

@implementation PWView

- (instancetype)init {
	if (self = [super init]) {
		
		self.userInteractionEnabled = YES;
		
		// create PWBackgroundView
		_backgroundView = [PWBackgroundView new];
		[self addSubview:_backgroundView];
	}
	return self;
}

- (void)layoutSubviews {
	
	if ([PWController activeWidget] == nil) return;
	
	LOG(@"PWView layoutSubviews");
	
	// container's rect
	CGRect containerRect = [self containerRect];
	
	if (CGRectEqualToRect(containerRect, CGRectZero)) {
		LOG(@"PWView retrieved container rect (CGRectZero)");
		return;
	}
	
	LOG(@"PWView retrieved container rect (%@)", NSStringFromCGRect(containerRect));
	LOG(@"PWView _containerView = %@", _containerView);
	
	// update the frame of container view
	_containerView.frame = containerRect;
	[_containerView layoutIfNeeded];
	
	LOG(@"PWView set layout for container view");
	
	[self _updateBackgroundViewRect:containerRect animated:NO];
	
	LOG(@"PWView updated background view rect");
}

- (void)createContainerView {
	
	if (_containerView != nil) return;
	
	// create container view
	_containerView = [PWContainerView new];
	[self addSubview:_containerView];
	
	// add navigation controller view to it
	UIView *view = [PWController activeWidget].navigationController.view;
	_containerView.navigationControllerView = view;
	[_containerView addSubview:view];
}

- (void)removeContainerView {
	if (_containerView == nil) return;
	RELEASE_VIEW(_containerView)
}

- (void)keyboardWillShow:(CGFloat)height {
	
	if ([PWController sharedInstance].isAnimating) return;
	
	PWWidget *widget = [PWController activeWidget];
	id<PWContentViewControllerDelegate> viewController = widget.topViewController;
	BOOL requiresKeyboard = viewController.requiresKeyboard;
	
	if (!requiresKeyboard) return;
	
	CGFloat oldHeight = _containerView.keyboardHeight;
	if (oldHeight == height) return; // no change
	
	CGFloat difference = (height - oldHeight) / 2;
	CGRect toRect = _containerView.frame;
	toRect.origin.y -= difference;
	
	_containerView.keyboardHeight = height;
	
	[UIView animateWithDuration:PWAnimationDuration animations:^{
		_containerView.frame = toRect;
	}];
	
	[self _updateBackgroundViewRect:toRect animated:YES];
}

- (void)keyboardWillHide {
	
	if ([PWController sharedInstance].isAnimating) return;
	
	PWWidget *widget = [PWController activeWidget];
	id<PWContentViewControllerDelegate> viewController = widget.topViewController;
	BOOL requiresKeyboard = viewController.requiresKeyboard;
	
	PWWidgetOrientation currentOrientation = [PWController currentOrientation];
	
	CGRect toRect = _containerView.frame;
	
	if (!requiresKeyboard) {
		// reset keyboard height to zero
		//toRect.origin.y += _containerView.keyboardHeight / 2;
		//_containerView.keyboardHeight = 0.0;
		return;
	} else {
		// reset keyboard height to default value
		CGFloat oldHeight = _containerView.keyboardHeight;
		CGFloat defaultHeight = [[PWController sharedInstance] defaultHeightOfKeyboardInOrientation:currentOrientation];
		if (oldHeight == defaultHeight) return; // no change
		toRect.origin.y += (defaultHeight - oldHeight) / 2;
		_containerView.keyboardHeight = defaultHeight;
	}
	
	[UIView animateWithDuration:PWAnimationDuration animations:^{
		_containerView.frame = toRect;
	}];
	
	[self _updateBackgroundViewRect:toRect animated:YES];
}

- (CGRect)containerRect {
	
	PWController *controller = [PWController sharedInstance];
	PWWidget *widget = [PWController activeWidget];
	id<PWContentViewControllerDelegate> viewController = widget.topViewController;
	
	LOG(@"containerRect: <%@> <%@>", widget, viewController);
	
	if (widget == nil || viewController == nil || ![viewController.class conformsToProtocol:@protocol(PWContentViewControllerDelegate)])
		return CGRectZero;
	
	PWWidgetOrientation orientation = [PWController currentOrientation];
	
	//BOOL shouldMaximizeContentHeight = viewController.shouldMaximizeContentHeight;
	BOOL requiresKeyboard = viewController.requiresKeyboard;
	
	// maximum size and height
	CGSize selfSize = self.bounds.size;
	CGFloat availableHeight = [controller availableHeightInOrientation:orientation withKeyboard:requiresKeyboard];
	
	// view dimensions
	CGFloat width = selfSize.width;
	CGFloat height = selfSize.height;
	
	// calculate container width
	CGFloat contentWidth = [viewController contentWidthForOrientation:orientation];
	CGFloat containerWidth = MIN(contentWidth, width);
	
	// calculate container height
	/*
	CGFloat containerHeight = 0.0;
	if (shouldMaximizeContentHeight) {
		containerHeight = availableHeight;
	} else {
		CGFloat contentHeight = [viewController contentHeightForOrientation:orientation];
		CGFloat navigationBarHeight = [controller heightOfNavigationBarInOrientation:orientation];
		containerHeight = MIN(MAX(0.0, contentHeight + navigationBarHeight), availableHeight);
	}*/
	CGFloat contentHeight = [viewController contentHeightForOrientation:orientation];
	CGFloat navigationBarHeight = [controller heightOfNavigationBarInOrientation:orientation];
	CGFloat containerHeight = MIN(MAX(0.0, contentHeight + navigationBarHeight), availableHeight);
	
	// container's dimensions and origins
	CGFloat containerLeft = (width - containerWidth) / 2;
	CGFloat containerTop = (height - containerHeight) / 2;
	
	// requires keyboard
	if (requiresKeyboard) {
		if (_containerView.keyboardHeight == 0) {
			_containerView.keyboardHeight = [controller defaultHeightOfKeyboardInOrientation:orientation];
		}
		containerTop -= (_containerView.keyboardHeight) / 2;
	}
	
	// container's rect
	return CGRectMake(containerLeft, containerTop, containerWidth, containerHeight);
}

// update the frame of mask layer
- (void)_updateBackgroundViewRect:(CGRect)rect animated:(BOOL)animated {
	
	LOG(@"_updateBackgroundViewRect: %@", animated ? @"YES" : @"NO");
	
	CGFloat extraSize = PWSheetMotionEffectDistance;
	CGFloat cornerRadius = [[PWController activeTheme] cornerRadius];
	_backgroundView.frame = CGRectInset(self.bounds, -extraSize, -extraSize);
	[_backgroundView setMaskRect:rect cornerRadius:cornerRadius animated:animated];
}

- (void)_resizeWidgetAnimated:(BOOL)animated {
	
	LOG(@"_resizeWidgetAnimated: %@", animated ? @"YES" : @"NO");
	
	CGRect currentRect = _containerView.frame;
	CGRect rect = [self containerRect];
	
	if (CGRectEqualToRect(currentRect, rect)) {
		LOG(@"_resizeWidgetAnimated: rect remains unchanged");
		return;
	}
	
	if ([PWController sharedInstance].isAnimating) {
		animated = NO;
	}
	
	if (!animated) {
		_containerView.frame = rect;
		[self _updateBackgroundViewRect:rect animated:NO];
	} else {
		
		[UIView animateWithDuration:PWAnimationDuration delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionNone animations:^{
			_containerView.frame = rect;
			[_containerView setNeedsLayout];
			// not the the line below is necessary
			//[_containerView layoutIfNeeded];
		} completion:nil];
		
		[self _updateBackgroundViewRect:rect animated:YES];
	}
}

- (void)dealloc {
	
	RELEASE_VIEW(_backgroundView)
	RELEASE_VIEW(_containerView)
	
	[super dealloc];
}

@end