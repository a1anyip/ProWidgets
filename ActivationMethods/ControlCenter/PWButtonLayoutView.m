//
//  ProWidgetsSection.m
//  ProWidgets
//
//  Created by Alan on 29.01.2014.
//  Copyright (c) 2014 Alan. All rights reserved.
//

#import "interface.h"

extern NSUInteger iconPerPage;

%subclass PWButtonLayoutView : SBCCButtonLayoutView

- (void)layoutSubviews {
	
	%orig;
	//[super layoutSubviews];
	
	NSArray *buttons = self.buttons;
	NSUInteger count = [buttons count];
	if (count == 0) return;
	
	UIView *button = buttons[0];
	CGSize buttonSize = button.bounds.size;
	CGFloat buttonWidth = 60.0;//buttonSize.width;
	CGFloat buttonHeight = buttonSize.height;
	
	CGFloat width = self.bounds.size.width;
	CGFloat height = self.bounds.size.height;
	
	iconPerPage = MAX(1, iconPerPage);
	CGFloat top = (height - buttonHeight) / 2;
	CGFloat separation = (width - buttonWidth * iconPerPage) / (iconPerPage + 1);
	
	NSUInteger i = 0;
	for (UIView *button in buttons) {
		CGRect rect = CGRectMake(separation * (i + 1) + buttonWidth * i, top, buttonWidth, buttonHeight);
		button.frame = rect;
		i++;
	}
	
}

%end