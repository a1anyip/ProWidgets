//
//  ProWidgets
//  Default Blur Theme
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWController.h"
#import "PWTheme.h"
#import "PWContainerView.h"

@interface _UIBackdropView : UIView

- (id)initWithSettings:(id)settings;

@end

@interface _UIBackdropViewSettings : NSObject

@property(nonatomic, retain) UIColor *colorTint;
@property(nonatomic) float colorTintAlpha;
@property(nonatomic) float saturationDeltaFactor;

+ (instancetype)settingsForStyle:(int)style;
- (instancetype)initWithDefaultValues;

@end

@interface UINavigationBar (Private)

- (UIView *)_backgroundView;

@end

@interface PWWidgetThemeBlur : PWTheme {
	
	UIView *_barBlurView;
	UIView *_contentBlurView;
}

@end

@implementation PWWidgetThemeBlur

/**
 * Override these methods
 **/

- (CGFloat)cornerRadius {
	return 7.0;
}

- (UIColor *)tintColor {
	return [self preferredTintColor] == nil ? [super tintColor] : [self preferredTintColor];
}

- (UIColor *)sheetForegroundColor {
	return [UIColor blackColor];
}

- (UIColor *)sheetBackgroundColor {
	return [UIColor clearColor];
}

- (UIColor *)navigationBarBackgroundColor {
	return [UIColor clearColor];
}

// navigation bar title
- (UIColor *)navigationTitleTextColor {
	return [self preferredBarTextColor] == nil ? [super navigationButtonTextColor] : [self preferredBarTextColor];
}

// navigation bar buttons
- (UIColor *)navigationButtonTextColor {
	return [self preferredBarTextColor] == nil ? [super navigationButtonTextColor] : [[self preferredBarTextColor] colorWithAlphaComponent:.6];
}

- (UIColor *)cellButtonTextColor {
	return [self preferredTintColor] == nil ? [super cellButtonTextColor] : [PWTheme darkenColor:[self preferredTintColor]];
}

// cell selected background color
- (UIColor *)cellSelectedBackgroundColor {
	return [self preferredTintColor] == nil ? [super cellSelectedBackgroundColor] : [[self preferredTintColor] colorWithAlphaComponent:.1];
}

- (UIColor *)cellSelectedButtonTextColor {
	return [self preferredTintColor] == nil ? [super cellSelectedButtonTextColor] : [PWTheme darkenColor:[self preferredTintColor]];
}

// header footer view
- (UIColor *)cellHeaderFooterViewBackgroundColor {
	return [self preferredTintColor] == nil ? [super cellSelectedBackgroundColor] : [[self preferredTintColor] colorWithAlphaComponent:.1];
}

- (UIColor *)cellHeaderFooterViewTitleTextColor {
	return [self preferredTintColor] == nil ? [super cellSelectedButtonTextColor] : [PWTheme darkenColor:[self preferredTintColor]];
}

// switch
- (UIColor *)switchOnColor {
	return [self preferredTintColor] == nil ? [super switchOnColor] : [[self preferredTintColor] colorWithAlphaComponent:.8];
}

- (UIColor *)switchOffColor {
	return [self preferredTintColor] == nil ? [super switchOffColor] : [UIColor colorWithWhite:0 alpha:.2];
}

- (void)enterSnapshotMode {
	if (!self.disabledBlur) {
		UIColor *barTintColor = [self preferredTintColor];
		BOOL shouldTintBar = barTintColor != nil;
		if (shouldTintBar) {
			_barBlurView.backgroundColor = barTintColor;
		} else {
			_barBlurView.backgroundColor = [UIColor whiteColor];
		}
		_contentBlurView.backgroundColor = [UIColor whiteColor];
	}
}

- (void)exitSnapshotMode {
	if (!self.disabledBlur) {
		_barBlurView.backgroundColor = [UIColor clearColor];
		_contentBlurView.backgroundColor = [UIColor clearColor];
	}
}

- (void)setupTheme {
	
	UINavigationBar *navigationBar = [self navigationBar];
	PWContainerView *containerView = [self containerView];
	
	UIColor *barTintColor = [self preferredTintColor];
	BOOL shouldTintBar = barTintColor != nil;
	
	// make the navigation bar transparent
	navigationBar.translucent = NO;
	
	UIView *backgroundView = [navigationBar _backgroundView];
	backgroundView.backgroundColor = [UIColor clearColor]; // remove white background
	
	if (self.disabledBlur) {
		
		CGFloat alpha = .96;
		
		_barBlurView = [UIView new];
		_barBlurView.backgroundColor = barTintColor;
		_barBlurView.alpha = alpha;
		[containerView insertSubview:_barBlurView atIndex:0];
		
		_contentBlurView = [UIView new];
		_contentBlurView.backgroundColor = [UIColor whiteColor];
		_contentBlurView.alpha = alpha;
		[containerView insertSubview:_contentBlurView atIndex:0];
		
	} else {
		
		// backdrop view settings
		_UIBackdropViewSettings *barSettings = nil;
		_UIBackdropViewSettings *contentSettings = [[[objc_getClass("_UIBackdropViewSettingsUltraLight") alloc] initWithDefaultValues] autorelease];
		
		if (shouldTintBar) {
			barSettings = [[[objc_getClass("_UIBackdropViewSettingsColored") alloc] initWithDefaultValues] autorelease];
			barSettings.colorTint = barTintColor;
			barSettings.saturationDeltaFactor = 0.0;
		} else {
			barSettings = [[[objc_getClass("_UIBackdropViewSettingsUltraLight") alloc] initWithDefaultValues] autorelease];
		}
		
		// add blur view as the background
		_barBlurView = [[objc_getClass("_UIBackdropView") alloc] initWithSettings:barSettings];
		[containerView insertSubview:_barBlurView atIndex:0];
		
		_contentBlurView = [[objc_getClass("_UIBackdropView") alloc] initWithSettings:contentSettings];
		[containerView insertSubview:_contentBlurView atIndex:0];
	}
}

- (void)removeTheme {
	
	[_barBlurView removeFromSuperview];
	[_contentBlurView removeFromSuperview];
	
	[_barBlurView release], _barBlurView = nil;
	[_contentBlurView release], _contentBlurView = nil;
}

- (void)adjustLayout {
	
	CGRect superRect = [self containerView].bounds;
	CGSize superSize = superRect.size;
	
	_barBlurView.frame = CGRectMake(0, 0, superSize.width, [self navigationBar].bounds.size.height);
	_contentBlurView.frame = CGRectMake(0, _barBlurView.frame.size.height, superSize.width, superSize.height - _barBlurView.frame.size.height);
}

- (void)dealloc {
	
	[_barBlurView removeFromSuperview];
	[_contentBlurView removeFromSuperview];
	
	[_barBlurView release], _barBlurView = nil;
	[_contentBlurView release], _contentBlurView = nil;
	
	[super dealloc];
}

@end