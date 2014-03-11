//
//  ProWidgets
//  Bootstrap (inject the library into SpringBoard)
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "interface.h"
#import "header.h"
#import "PWController.h"
#import "PWWidgetController.h"

#define LS_PREF_PATH @"/var/mobile/Library/Preferences/cc.tweak.prowidgets.activationmethod.lockscreen.plist"
#define NOTIFICATION_NAME @"cc.tweak.prowidgets.activationmethod.lockscreen.preferencechanged"

#define BTN_TAG 1001
#define BTN_INITIAL_ALPHA .3

// settings
CGFloat buttonWidth = 45.0;
CGFloat buttonHeight = 35.0;
CGFloat imageHeight = 25.0;

// preference values
static NSString *widgetName = nil;

// runtime variables
static UIButton *button = nil;

static inline void buttonPressed() {
	if (widgetName != nil) {
		NSDictionary *userInfo = @{ @"from": @"lockscreen" };
		// present the widget
		[PWWidgetController presentWidgetNamed:widgetName userInfo:userInfo];
	}
}

static inline UIImage *processImage(UIImage *image, BOOL tint) {
	
	if (image == nil || image.size.width == 0 || image.size.height == 0) return nil;
	
	// calculate the scaled image size
	CGFloat width = image.size.width;
	CGFloat height = image.size.height;
	
	if (height > imageHeight) {
		CGFloat factor = imageHeight / height;
		width *= factor;
		height = imageHeight;
	}
	
	CGRect rect = CGRectMake(0, 0, width, height);
	
	UIGraphicsBeginImageContextWithOptions(rect.size, NO, image.scale);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	transform = CGAffineTransformScale(transform, 1.0, -1.0);
	transform = CGAffineTransformTranslate(transform, 0.0, -image.size.height);
	CGContextConcatCTM(context, transform);
	
	CGRect flippedRect = CGRectApplyAffineTransform(rect, transform);
	CGContextDrawImage(context, flippedRect, image.CGImage);
	
	UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return tint ? [result imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] : result;
}

static inline void createButton() {
	// create a new one
	button = [UIButton new];
	button.tag = BTN_TAG;
	button.userInteractionEnabled = YES;
	button.adjustsImageWhenHighlighted = YES;
	button.showsTouchWhenHighlighted = NO;
	button.backgroundColor = [UIColor clearColor];
	
	//CGColorRef color = [[objc_getClass("SBWallpaperController") sharedInstance] homescreenLightForegroundBlurColor];
	//UIColor *tintColor = [UIColor colorWithCGColor:color];
	
	button.imageView.tintColor = [UIColor whiteColor];
	button.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

static inline void updateButton(NSString *widgetName) {
	
	if (button == nil) {
		createButton();
	}
	
	PWController *controller = [PWController sharedInstance];
	NSDictionary *info = [controller infoOfWidgetNamed:widgetName];
	NSBundle *bundle = info[@"bundle"];
	NSString *maskFile = info[@"maskFile"];
	NSString *iconFile = info[@"iconFile"];
	
	if (bundle == nil || (maskFile == nil && iconFile == nil)) {
		button.hidden = YES;
		return;
	}
	
	UIImage *image = nil;
	
	if (maskFile != nil) {
		image = processImage([UIImage imageNamed:maskFile inBundle:bundle], YES);
	}
	
	if (image == nil && iconFile != nil) {
		image = processImage([UIImage imageNamed:iconFile inBundle:bundle], NO);
	}
	
	if (image == nil) {
		button.hidden = YES;
		return;
	}
	
	button.alpha = BTN_INITIAL_ALPHA;
	button.hidden = NO;
	[button setImage:image forState:UIControlStateNormal];
}

%hook SBLockScreenBounceAnimator

- (void)_handleTapGesture:(UITapGestureRecognizer *)gestureRecognizer {
	
	CGPoint location = [gestureRecognizer locationInView:button];
	BOOL contains = CGRectContainsPoint(button.bounds, location);
	
	if (!button.hidden && contains) {
		buttonPressed();
	} else {
		%orig;
	}
}

%end

%hook SBLockScreenView

- (void)_layoutLockView {
	
	%orig;
	
	UIView *lockView = *(UIView **)instanceVar(self, "_foregroundLockView");
	if (lockView != nil) {
		
		UIView *buttonSubview = [lockView viewWithTag:BTN_TAG];
		if (buttonSubview == nil) {
			[button removeFromSuperview];
			[lockView addSubview:button];
		}
		
		CGRect rect = lockView.bounds;
		button.frame = CGRectMake(0.0, rect.size.height - buttonHeight, buttonWidth, buttonHeight);
	}
}

%end

// Loading preference
static inline void loadPref() {
	
	NSDictionary *pref = [[NSDictionary alloc] initWithContentsOfFile:LS_PREF_PATH];
	widgetName = [pref[@"widget"] copy];
	[pref release];
	
	if (widgetName == nil) {
		widgetName = [@"Browser" copy];
	}
	
	updateButton(widgetName);
}

static inline void reloadPref(CFNotificationCenterRef center,
							  void *observer,
							  CFStringRef name,
							  const void *object,
							  CFDictionaryRef userInfo) {
	// then, load preference
	loadPref();
}

static __attribute__((constructor)) void init() {
	
	// load preferences
	loadPref();
	
	// distributed notification center
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &reloadPref, CFSTR("cc.tweak.prowidgets.activationmethod.lockscreen.preferencechanged"), NULL, 0);

}