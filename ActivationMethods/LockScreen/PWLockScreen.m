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

static inline UIImage *processImage(UIImage *image) {
	
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
	
	return result;
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

@interface CALayer ()

@property(nonatomic) BOOL allowsGroupBlending;

@end

static inline void updateButton(NSString *widgetName) {
	
	if (button == nil) {
		//createButton();
		return;
	}
	
	PWController *controller = [PWController sharedInstance];
	NSDictionary *info = [controller infoOfWidgetNamed:widgetName];
	NSBundle *bundle = info[@"bundle"];
	NSString *maskFile = info[@"maskFile"];
	
	if (bundle == nil) {
		button.hidden = YES;
		return;
	}
	
	UIImage *image = nil;
	
	if (maskFile != nil) {
		image = [UIImage imageNamed:maskFile inBundle:bundle];
	}
	
	// unknown icon (fallback)
	if (image == nil) {
		image = [[PWController sharedInstance] imageResourceNamed:@"unknownMask"];
	}
	
	if (image == nil) {
		button.hidden = YES;
		return;
	}
	
	// scale it
	image = processImage(image);
	
	// remove all subviews
	[button.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	
	button.alpha = 1.0;//BTN_INITIAL_ALPHA;
	button.hidden = NO;
	button.clipsToBounds = YES;
	button.opaque = NO;
	//button.layer.allowsGroupBlending = NO;
	
	CGSize buttonSize = button.bounds.size;
	CGSize size = image.size;
	
	CALayer *mask = [CALayer layer];
	mask.contents = (id)image.CGImage;
	mask.frame = CGRectMake((buttonSize.width - size.width) / 2, (buttonSize.height - size.height) / 2, size.width, size.height);
	button.layer.mask = mask;
	button.layer.masksToBounds = YES;
	
	SBWallpaperEffectView *wallpaperEffect = [[objc_getClass("SBWallpaperEffectView") alloc] initWithWallpaperVariant:0];
	wallpaperEffect.frame = button.bounds;
	wallpaperEffect.style = 6;
	[wallpaperEffect setMaskImage:image masksBlur:NO masksTint:NO];
	[button addSubview:wallpaperEffect];
	[wallpaperEffect release];
	/*
	CGRect frame = button.bounds;
	UIColor *color = *(UIColor **)instanceVar(wallpaperEffect, "_wallpaperAverageColor"); //[UIColor colorWithWhite:.9 alpha:1.0];
	NSInteger style = [objc_getClass("_UILegibilitySettingsProvider") styleForContentColor:color];
	NSInteger vibrantStyle = style == 2 ? 1 : 0;
	*/
	//_SBFVibrantSettings *settings = [objc_getClass("_SBFVibrantSettings") vibrantSettingsWithReferenceColor:nil legibilitySettings:nil];
	/*
	Ivar settingsStyle = class_getInstanceVariable(objc_getClass("_SBFVibrantSettings"), "_style");
	if (settingsStyle) {
		NSInteger *settingsStylePointer = (NSInteger *)((uint8_t *)(void *)settings + ivar_getOffset(settingsStyle));
		*settingsStylePointer = vibrantStyle;
	}*/
	
    /*
	UIView *colorCompositingView = [settings colorCompositingViewWithFrame:button.bounds];
	[button addSubview:colorCompositingView];
	
	UIView *darkTintView = [settings darkTintViewWithFrame:button.bounds];
	[button addSubview:darkTintView];
	
	UIView *lightTintView = [settings lightTintViewWithFrame:button.bounds];
	[button addSubview:lightTintView];*/
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
		
		if (button == nil) {
			createButton();
		}
		
		UIView *buttonSubview = [lockView viewWithTag:BTN_TAG];
		if (buttonSubview == nil) {
			[button removeFromSuperview];
			[lockView addSubview:button];
		}
		
		CGRect rect = lockView.bounds;
		button.frame = CGRectMake(0.0, rect.size.height - buttonHeight, buttonWidth, buttonHeight);
		
		updateButton(widgetName);
	}
}

%end

// Loading preference
static inline void loadPref() {
	
	[widgetName release];
	
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