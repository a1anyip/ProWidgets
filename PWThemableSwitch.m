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

- (instancetype)init {
	if ((self = [super init])) {
		[self _configureAppearance];
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[self _configureAppearance];
	}
	return self;
}

- (void)_configureAppearance {
	
	PWTheme *theme = [PWController activeTheme];
	
	UIColor *switchOnColor = [theme cellSwitchOnColor];
	UIColor *switchOffColor = [theme cellSwitchOffColor];
	
	self.tintColor = switchOffColor;
	self.onTintColor = switchOnColor;
}

@end