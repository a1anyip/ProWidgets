//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWThemableTextView.h"
#import "PWController.h"
#import "PWTheme.h"

@implementation PWThemableTextView

- (instancetype)initWithFrame:(CGRect)frame theme:(PWTheme *)theme {
	if ((self = [super initWithFrame:frame])) {
		[self _configureAppearance:theme];
	}
	return self;
}

- (void)_configureAppearance:(PWTheme *)theme {
	
	UIColor *backgroundColor = [theme cellBackgroundColor];
	UIColor *inputTextColor = [theme cellInputTextColor];
	
	self.backgroundColor = backgroundColor;
	
	self.textColor = inputTextColor;
	self.tintColor = [PWTheme adjustColorBrightness:inputTextColor colorAdjustment:0.0 alphaMultiplier:.3];
	
	self.keyboardAppearance = theme.wantsDarkKeyboard ? UIKeyboardAppearanceDark : UIKeyboardAppearanceDefault;
	
	self.textContainer.lineFragmentPadding = 0;
	self.font = [UIFont systemFontOfSize:18];
	
	// add padding
	CGFloat padding = PWDefaultItemCellPadding;
	self.textContainerInset = UIEdgeInsetsMake(padding, padding, padding, padding);
}

@end