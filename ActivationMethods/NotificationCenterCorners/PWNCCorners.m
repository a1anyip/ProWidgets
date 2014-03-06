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

#define PrefPath @"/var/mobile/Library/Preferences/cc.tweak.prowidgets.nccorners.plist"

#define ANIMATION_DURATION 0.1
#define BTN_TAG 1001
#define BTN_INITIAL_ALPHA .3
#define BTN_PRESSED_ALPHA .8

// settings
CGFloat buttonWidth = 50.0;
CGFloat buttonHeight = 30.0;
CGFloat imageHeight = 20.0;

// preference values
BOOL enabled = NO;
NSString *leftWidgetName = nil;
NSString *rightWidgetName = nil;

// runtime variables
UIButton *leftButton = nil;
UIButton *rightButton = nil;

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
	
	if (tint) {
		CGContextSetBlendMode(context, kCGBlendModeNormal);
		[[UIColor whiteColor] setFill];
		CGContextFillRect(context, flippedRect);
		CGContextSetBlendMode(context, kCGBlendModeDestinationIn);
		CGContextDrawImage(context, flippedRect, image.CGImage);
	} else {
		CGContextDrawImage(context, flippedRect, image.CGImage);
	}
	
	UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return result;
}

static inline UIButton *createButton(id target) {
	UIButton *button = [UIButton new];
	button.adjustsImageWhenHighlighted = YES;
	button.showsTouchWhenHighlighted = NO;
	button.backgroundColor = [UIColor clearColor];
	button.imageView.contentMode = UIViewContentModeScaleAspectFit;
	//[button addTarget:target action:@selector(PW_touchDown:) forControlEvents:UIControlEventTouchDown];
	//[button addTarget:target action:@selector(PW_touchUp:) forControlEvents:UIControlEventTouchUpInside];
	[button addTarget:target action:@selector(PW_pressed:) forControlEvents:UIControlEventTouchUpInside];
	return button;
}

static inline void configureButton(UIView *containerView, UIButton *button, BOOL right) {
	
	CGSize size = containerView.bounds.size;
	
	if (right) {
		button.frame = CGRectMake(size.width - buttonWidth, size.height - buttonHeight, buttonWidth, buttonHeight);
		button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
	} else {
		button.frame = CGRectMake(0, size.height - buttonHeight, buttonWidth, buttonHeight);
		button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
	}
}

static inline void updateButton(UIButton *button, NSString *widgetName) {
	
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

static inline void updateButtons() {
	if (!enabled) {
		leftButton.hidden = YES;
		rightButton.hidden = YES;
	} else {
		updateButton(leftButton, leftWidgetName);
		updateButton(rightButton, rightWidgetName);
	}
}

static inline void loadPreference() {
	
	[leftWidgetName release];
	[rightWidgetName release];
	
	NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:PrefPath];
	enabled = [dict[@"enabled"] boolValue];
	leftWidgetName = [dict[@"leftWidgetName"] copy];
	rightWidgetName = [dict[@"rightWidgetName"] copy];
	[dict release];
	
	enabled = YES;
	leftWidgetName = [@"Mail" copy];
	rightWidgetName = [@"Messages" copy];
	
	updateButtons();
}

static inline void reloadPref(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	loadPreference();
}

%hook SBNotificationCenterViewController

- (void)viewWillAppear:(BOOL)view {
	%orig;
	loadPreference();
}

- (void)viewDidLoad {
	
	%orig;
	
	// remove old buttons
	if (leftButton != nil && rightButton != nil) {
		[leftButton removeFromSuperview];
		[rightButton removeFromSuperview];
		[leftButton release], leftButton = nil;
		[rightButton release], rightButton = nil;
	}
	
	UIView *containerView = *(UIView **)instanceVar(self, "_containerView");
	if (containerView != NULL) {
		
		// create buttons
		leftButton = createButton(self);
		rightButton = createButton(self);
		
		// configure button's position
		configureButton(containerView, leftButton, NO);
		configureButton(containerView, rightButton, YES);
		
		[containerView addSubview:leftButton];
		[containerView addSubview:rightButton];
	}
}
/*
%new(v@:@)
- (void)PW_touchDown:(UIButton *)button {
	[UIView animateWithDuration:ANIMATION_DURATION animations:^{
		button.alpha = BTN_PRESSED_ALPHA;
	}];
}

%new(v@:@)
- (void)PW_touchUp:(UIButton *)button {
	[UIView animateWithDuration:ANIMATION_DURATION animations:^{
		button.alpha = BTN_INITIAL_ALPHA;
	}];
}
*/
%new(v@:@)
- (void)PW_pressed:(UIButton *)button {
	
	NSString *widgetName = nil;
	if (button == leftButton) {
		widgetName = leftWidgetName;
	} else if (button == rightButton) {
		widgetName = rightWidgetName;
	}
	
	if (widgetName != nil) {
		NSDictionary *userInfo = @{ @"from": @"notificationcentercorner" };
		//[[PWController sharedInstance] presentWidgetNamed:widgetName userInfo:userInfo];
		[PWWidgetController presentWidgetNamed:widgetName userInfo:userInfo];
	}
}

%end

__attribute__((constructor))
static inline void init() {
	// add observer to reload preference
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &reloadPref, CFSTR("cc.tweak.prowidgets.nccorners.preferencechanged"), NULL, 0);
}