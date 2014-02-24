//
//  ProWidgetsSection.m
//  ProWidgets
//
//  Created by Alan on 29.01.2014.
//  Copyright (c) 2014 Alan. All rights reserved.
//

#import "interface.h"

extern NSUInteger iconPerPage;

%subclass PWNCButtonLayoutView : SBCCButtonLayoutView

- (void)layoutSubviews {
	
	%orig;
	
	NSArray *buttons = self.buttons;
	NSUInteger count = [buttons count];
	if (count == 0) return;
	
	CGFloat horizontalMargin = 10.0;//16.0;
	CGFloat buttonWidth = 47.0;
	CGFloat buttonHeight = 47.0;
	
	CGFloat width = self.bounds.size.width;
	CGFloat height = self.bounds.size.height;
	
	iconPerPage = MAX(1, iconPerPage);
	CGFloat top = (height - buttonHeight) / 2;
	CGFloat separation = (width - buttonWidth * iconPerPage - horizontalMargin * 2) / (iconPerPage + 1);
	
	NSUInteger i = 0;
	for (UIView *button in buttons) {
		CGRect rect = CGRectMake(horizontalMargin + separation * (i + 1) + buttonWidth * i, top, buttonWidth, buttonHeight);
		button.frame = rect;
		i++;
	}
}

%end