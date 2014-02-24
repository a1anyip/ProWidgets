//
//  ProWidgetsSection.m
//  ProWidgets
//
//  Created by Alan on 29.01.2014.
//  Copyright (c) 2014 Alan. All rights reserved.
//

#import "interface.h"

%subclass PWNCButton : SBControlCenterButton

- (void)_updateSelected:(BOOL)selected highlighted:(BOOL)highlighted {
	%orig(NO, YES);
	[UIView animateWithDuration:.1 animations:^{
		if (highlighted) {
			self.alpha = 1.0;
		} else {
			self.alpha = 0.4;
		}
	}];
}

%end