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

@interface UINavigationBar (backgroundView)

- (UIView *)_backgroundView;

@end

@interface PWWidgetThemeDarkBlur : PWTheme {
	
	UIView *_barView;
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
	return [UIColor colorWithWhite:0 alpha:.1];
}

- (UIColor *)cellTitleTextColor {
	return [UIColor colorWithWhite:1.0 alpha:.25];
}

- (UIColor *)cellValueTextColor {
	return [UIColor colorWithWhite:1.0 alpha:.35];
}

- (UIColor *)cellButtonTextColor {
	return [UIColor colorWithWhite:1 alpha:.35];
}

- (UIColor *)cellInputTextColor {
	return [UIColor colorWithWhite:1 alpha:.5];
}

- (UIColor *)cellInputPlaceholderTextColor {
	return [UIColor colorWithWhite:1 alpha:.2];
}

- (UIColor *)cellPlainTextColor {
	return [UIColor colorWithWhite:1 alpha:.2];
}

// cell selected background color
- (UIColor *)cellSelectedBackgroundColor {
	return [UIColor colorWithWhite:0 alpha:.2];
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
	return [UIColor colorWithWhite:.1 alpha:1.0];
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

- (void)enterSnapshotMode {
	if (!self.disabledBlur) {
		_barView.backgroundColor = [UIColor blackColor];
	}
}

- (void)exitSnapshotMode {
	if (!self.disabledBlur) {
		_barView.backgroundColor = [UIColor clearColor];
	}
}

- (void)setupTheme {
	
	UINavigationBar *navigationBar = [self navigationBar];
	PWContainerView *containerView = [self containerView];
	
	navigationBar.translucent = NO;
	
	UIView *backgroundView = [navigationBar _backgroundView];
	backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:.3]; // remove white background
	
	if (self.disabledBlur) {
		
		CGFloat alpha = .98;
		
		_barView = [UIView new];
		_barView.backgroundColor = [UIColor blackColor];
		_barView.alpha = alpha;
		[containerView insertSubview:_barView atIndex:0];
		
	} else {
	
		// backdrop view settings
		_UIBackdropViewSettings *barSettings = [[[objc_getClass("_UIBackdropViewSettingsColored") alloc] initWithDefaultValues] autorelease];
		
		barSettings.colorTint = [UIColor blackColor];
		barSettings.saturationDeltaFactor = 0.0;
		
		// add blur view as the background
		_barView = [[objc_getClass("_UIBackdropView") alloc] initWithSettings:barSettings];
		[containerView insertSubview:_barView atIndex:0];
	}
}

- (void)removeTheme {
	[_barView removeFromSuperview];
	[_barView release], _barView = nil;
}

- (void)adjustLayout {
	
	CGRect superRect = [self containerView].bounds;
	CGSize superSize = superRect.size;
	
	_barView.frame = CGRectMake(0, 0, superSize.width, superSize.height);
}

- (void)dealloc {
	
	[_barView removeFromSuperview];
	[_barView release], _barView = nil;
	
	[super dealloc];
}

@end