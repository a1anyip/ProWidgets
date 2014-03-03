//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"

@interface PWThemableTableViewCell : UITableViewCell {
	
	BOOL _configuredAppearance;
	UIView *_customSeparatorView;
}

+ (void)setSeparatorColor:(UIColor *)color;

//////////////////////////////////////////////////////////////////////

- (void)_configureAppearance;

////////// Normal //////////

- (void)setBackgroundImage:(UIImage *)image forOrientation:(PWWidgetOrientation)orientation;
- (void)setBackgroundColor:(UIColor *)color;
- (void)setTitleTextColor:(UIColor *)color;
- (void)setValueTextColor:(UIColor *)color;
- (void)setButtonTextColor:(UIColor *)color;
- (void)setInputTextColor:(UIColor *)color;
- (void)setInputPlaceholderTextColor:(UIColor *)color;
- (void)setPlainTextColor:(UIColor *)color;

////////// Selected //////////

- (void)setSelectedBackgroundImage:(UIImage *)image forOrientation:(PWWidgetOrientation)orientation;
- (void)setSelectedBackgroundColor:(UIColor *)color;
- (void)setSelectedTitleTextColor:(UIColor *)color;
- (void)setSelectedValueTextColor:(UIColor *)color;
- (void)setSelectedButtonTextColor:(UIColor *)color;

// Switch
- (void)setSwitchThumbColor:(UIColor *)color;
- (void)setSwitchOnColor:(UIColor *)color;
- (void)setSwitchOffColor:(UIColor *)color;

//////////////////////////////////////////////////////////////////////

@end