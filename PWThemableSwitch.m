//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWThemableSwitch.h"
#import "PWController.h"
#import "PWTheme.h"

@implementation PWThemableSwitch

- (instancetype)initWithFrame:(CGRect)frame theme:(PWTheme *)theme {
	if ((self = [super initWithFrame:frame])) {
		[self _configureAppearance:theme];
	}
	return self;
}

- (void)_configureAppearance:(PWTheme *)theme {
	
	UIColor *switchThumbColor = [theme switchThumbColor];
	UIColor *switchOnColor = [theme switchOnColor];
	UIColor *switchOffColor = [theme switchOffColor];
	
	self.thumbTintColor = switchThumbColor;
	self.tintColor = switchOffColor;
	self.onTintColor = switchOnColor;
}

@end