//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWThemableTextField.h"
#import "PWController.h"
#import "PWTheme.h"

@interface UITextField ()

- (UIColor *)_placeholderColor;
- (UIImage *)_clearButtonImageForState:(unsigned int)state;

@end

@implementation PWThemableTextField

- (instancetype)initWithFrame:(CGRect)frame theme:(PWTheme *)theme {
	if ((self = [super initWithFrame:frame])) {
		[self _configureAppearance:theme];
	}
	return self;
}

- (void)_configureAppearance:(PWTheme *)theme {
	
	UIColor *backgroundColor = [theme cellBackgroundColor];
	UIColor *inputTextColor = [theme cellInputTextColor];
	UIColor *inputPlaceholderTextColor = [theme cellInputPlaceholderTextColor];
	
	_cachedPlaceholderColor = [inputPlaceholderTextColor retain];
	
	self.backgroundColor = backgroundColor;
	
	self.textColor = inputTextColor;
	self.tintColor = [PWTheme adjustColorBrightness:inputTextColor colorAdjustment:0.0 alphaMultiplier:.3];
	
	self.keyboardAppearance = theme.wantsDarkKeyboard ? UIKeyboardAppearanceDark : UIKeyboardAppearanceDefault;
}

- (UIColor *)_placeholderColor {
	if (_cachedPlaceholderColor != nil) {
		return _cachedPlaceholderColor;
	} else {
		return [super _placeholderColor];
	}
}

- (void)dealloc {
	RELEASE(_cachedPlaceholderColor)
	[super dealloc];
}

@end