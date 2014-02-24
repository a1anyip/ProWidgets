//
//  ProWidgets
//  Default Blur Theme
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWTheme.h"
#import "PWContainerView.h"

enum UIBackdropViewSettings {
	_UIBackdropViewSettingsLight = 0,
	_UIBackdropViewSettingsDark = 1,
	_UIBackdropViewSettingsBlur = 2,
	_UIBackdropViewSettingsUltraLight = 3
};

@interface _UIBackdropView : UIView
- (id)initWithSettings:(id)settings;
@end

@interface _UIBackdropViewSettings : NSObject
+ (instancetype)settingsForStyle:(int)style;
@end

@interface UINavigationBar (Private)
- (UIView *)_backgroundView;
@end

@interface PWWidgetThemeTestTheme : PWTheme {
	
	_UIBackdropView *_blurView;
	_UIBackdropViewSettings *_blurSettings;
}

@end

@implementation PWWidgetThemeTestTheme

/**
 * Override these methods
 **/

- (CGFloat)cornerRadius {
	return 7.0;
}

- (void)setupTheme {
	
	//UINavigationController *navigationController = [self navigationController];
	UINavigationBar *navigationBar = [self navigationBar];
	
	// make the navigation bar transparent
	navigationBar.translucent = NO;
	
	UIView *backgroundView = [navigationBar _backgroundView];
	backgroundView.backgroundColor = [UIColor clearColor]; // remove white background
	
	/*
	_UIBackdropView *barBackDrop = *(_UIBackdropView **)instanceVar(backgroundView, "_adaptiveBackdrop");
	
	if (barBackDrop != nil) {
		[barBackDrop removeFromSuperview]; // remove blurred background
	}
	*/
	
	// Backdrop settings
	_UIBackdropViewSettings *settings = [objc_getClass("_UIBackdropViewSettings") settingsForStyle:_UIBackdropViewSettingsUltraLight];
	
	// add blur view as the background
	_blurView = [[objc_getClass("_UIBackdropView") alloc] initWithSettings:settings];
	[[self containerView] insertSubview:_blurView atIndex:0];
}

- (void)adjustLayout {
	CGRect superRect = [self containerView].bounds;
	_blurView.frame = superRect;
}

- (void)dealloc {
	[_blurView removeFromSuperview];
	[_blurView release], _blurView = nil;
	[super dealloc];
}

@end