//
//  ProWidgets
//  Dark Blur Theme
//
//  Created by Alan Yip on 5 Feb 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

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

@interface PWWidgetThemeDarkBlur : PWTheme {
	
	UIView *_barBlurView;
	UIView *_contentBlurView;
}

@end

@implementation PWWidgetThemeDarkBlur

/**
 * Override these methods
 **/

- (BOOL)wantsDarkKeyboard {
	return YES;
}

- (CGFloat)cornerRadius {
	return 7.0;
}

- (UIColor *)tintColor {
	return [UIColor colorWithWhite:.3 alpha:1.0];
}

- (UIColor *)sheetForegroundColor {
	return [UIColor colorWithWhite:1.0 alpha:.5];
}

- (UIColor *)sheetBackgroundColor {
	return [UIColor colorWithWhite:0.15 alpha:0.8];
}

- (UIColor *)navigationBarBackgroundColor {
	return [UIColor colorWithWhite:0.0 alpha:0.95];
}

// navigation bar title
- (UIColor *)navigationTitleTextColor {
	return [UIColor colorWithWhite:1 alpha:.3];
}

// navigation bar buttons
- (UIColor *)navigationButtonTextColor {
	return [UIColor colorWithWhite:1 alpha:.2];
}

- (UIColor *)cellSeparatorColor {
	return [UIColor colorWithWhite:.3 alpha:.3];
}

// cell selected background color
- (UIColor *)cellBackgroundColor {
	return [UIColor colorWithWhite:0 alpha:.2];
}

- (UIColor *)cellTitleTextColor {
	return [UIColor colorWithWhite:1.0 alpha:.2];
}

- (UIColor *)cellValueTextColor {
	return [UIColor colorWithWhite:1.0 alpha:.3];
}

- (UIColor *)cellButtonTextColor {
	return [UIColor colorWithWhite:1 alpha:.3];
}

- (UIColor *)cellInputTextColor {
	return [UIColor colorWithWhite:1 alpha:.5];
}

- (UIColor *)cellInputPlaceholderTextColor {
	return [UIColor colorWithWhite:1 alpha:.1];
}

- (UIColor *)cellPlainTextColor {
	return [UIColor colorWithWhite:1 alpha:.2];
}

// cell selected background color
- (UIColor *)cellSelectedBackgroundColor {
	return [UIColor colorWithWhite:0 alpha:.3];
}

- (UIColor *)cellSelectedTitleTextColor {
	return [UIColor colorWithWhite:1.0 alpha:.4];
}

- (UIColor *)cellSelectedValueTextColor {
	return [UIColor colorWithWhite:1.0 alpha:.3];
}

- (UIColor *)cellSelectedButtonTextColor {
	return [UIColor colorWithWhite:1 alpha:.3];
}

// header footer view
- (UIColor *)cellHeaderFooterViewBackgroundColor {
	return [UIColor colorWithWhite:.05 alpha:1.0];
}

- (UIColor *)cellHeaderFooterViewTitleTextColor {
	return [UIColor colorWithWhite:1.0 alpha:.2];
}

// switch
- (UIColor *)switchThumbColor {
	return [UIColor colorWithWhite:.4 alpha:1.0];
}

- (UIColor *)switchOnColor {
	return [UIColor colorWithWhite:1 alpha:.15];
}

- (UIColor *)switchOffColor {
	return [UIColor colorWithWhite:1 alpha:.1];
}

- (void)setupTheme {
	
	UINavigationBar *navigationBar = [self navigationBar];
	PWContainerView *containerView = [self containerView];
	
	// make the navigation bar transparent
	navigationBar.translucent = NO;
	
	UIView *backgroundView = [navigationBar _backgroundView];
	backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:.3]; // remove white background
	
	if (self.disabledBlur) {
		
		CGFloat alpha = .96;
		
		_barBlurView = [UIView new];
		_barBlurView.backgroundColor = [UIColor blackColor];
		_barBlurView.alpha = alpha;
		[containerView insertSubview:_barBlurView atIndex:0];
		
		_contentBlurView = [UIView new];
		_contentBlurView.backgroundColor = [UIColor blackColor];
		_contentBlurView.alpha = alpha;
		[containerView insertSubview:_contentBlurView atIndex:0];
		
	} else {
	
		// backdrop view settings
		_UIBackdropViewSettings *barSettings = [[[objc_getClass("_UIBackdropViewSettingsColored") alloc] initWithDefaultValues] autorelease];
		_UIBackdropViewSettings *contentSettings = [[[objc_getClass("_UIBackdropViewSettingsColored") alloc] initWithDefaultValues] autorelease];
		
		barSettings.colorTint = [UIColor blackColor];//barTintColor;
		barSettings.saturationDeltaFactor = 0.0;
		
		contentSettings.colorTint = [UIColor blackColor];//barTintColor;
		contentSettings.saturationDeltaFactor = 0.0;
		
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