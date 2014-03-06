//
//  ProWidgets
//  Bootstrap (inject the library into SpringBoard)
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "interface.h"
#import "header.h"
#import "PWController.h"
#import "PWWidgetController.h"

#define ANIMATION_DURATION 0.1
#define BTN_TAG 1001
#define BTN_INITIAL_ALPHA .3
#define BTN_PRESSED_ALPHA .8

static char PWTodayViewTomorrowSectionKey;

%hook SBTodayWidgetAndTomorrowSectionHeaderView

- (id)initWithFrame:(CGRect)frame {
	self = %orig;
	
	// add plus button
	UIButton *btn = [UIButton new];
	btn.exclusiveTouch = YES;
	btn.tag = BTN_TAG;
	btn.alpha = BTN_INITIAL_ALPHA;
	UIImage *btnImage = [[PWController sharedInstance] imageResourceNamed:@"todayViewAddButton"];
	[btn setImage:btnImage forState:UIControlStateNormal];
	[self addSubview:btn];
	[btn release];
	
	//[btn addTarget:self action:@selector(PW_touchDown) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragInside | UIControlEventTouchDragEnter];
	//[btn addTarget:self action:@selector(PW_touchUp) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchDragOutside | UIControlEventTouchDragExit | UIControlEventTouchCancel];
	[btn addTarget:self action:@selector(PW_pressed) forControlEvents:UIControlEventTouchUpInside];
	
	return self;
}

- (void)prepareForReuse {
	%orig;
	[self updateVisibility];
}

- (void)layoutSubviews {
	%orig;
	
	UIButton *btn = (UIButton *)[self viewWithTag:BTN_TAG];
	
	if (btn != nil) {
		[self updateVisibility];
		CGSize size = self.bounds.size;
		CGFloat width = size.width;
		CGFloat height = size.height;
		CGFloat buttonWidth = 45.0;
		CGFloat buttonHeight = 40.0;
		btn.frame = CGRectMake(width - buttonWidth, height - buttonHeight, buttonWidth, buttonHeight);
	}
}
/*
%new
- (void)PW_touchDown {
	UIButton *btn = (UIButton *)[self viewWithTag:BTN_TAG];
	[UIView animateWithDuration:ANIMATION_DURATION animations:^{
		btn.alpha = BTN_PRESSED_ALPHA;
	}];
}

%new
- (void)PW_touchUp {
	UIButton *btn = (UIButton *)[self viewWithTag:BTN_TAG];
	[UIView animateWithDuration:ANIMATION_DURATION animations:^{
		btn.alpha = BTN_INITIAL_ALPHA;
	}];
}
*/

%new
- (void)updateVisibility {
	
	UIButton *btn = (UIButton *)[self viewWithTag:BTN_TAG];
	
	if (btn != nil) {
		
		// determine whether the header view is for Calendar widget
		BOOL isCalendarWidget = NO;
		BOOL isTomorrowSection = NO;
		UITableView *tableView = self.tableView;
		NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:self.frame.origin];
		NSInteger section = indexPath.section;
		
		// retrieve SBBulletinViewController
		SBBulletinViewController *controller = (SBBulletinViewController *)tableView.delegate;
		if (controller != nil) {
			NSArray *sections = *(NSArray **)instanceVar(controller, "_orderedSections");
			if (sections != NULL) {
				if ([sections count] > section) {
					SBBBSectionInfo *sectionInfo = sections[section];
					NSString *identifier = sectionInfo.identifier;
					if ([identifier isEqualToString:@"com.apple.CalendarWidget"]) {
						isCalendarWidget = YES;
						isTomorrowSection = NO;
					} else if ([identifier isEqualToString:@"com.apple.springboard.notificationcenter.tomorrow"]) {
						isCalendarWidget = YES;
						isTomorrowSection = YES;
					}
				}
			}
		}
		
		btn.hidden = !isCalendarWidget;
		
		objc_setAssociatedObject(self, &PWTodayViewTomorrowSectionKey, @(isTomorrowSection), OBJC_ASSOCIATION_COPY);
	}
}

%new
- (void)PW_pressed {
	
	NSNumber *isTomorrowSection = (NSNumber *)objc_getAssociatedObject(self, &PWTodayViewTomorrowSectionKey);
	BOOL isTomorrow = isTomorrowSection != nil && [isTomorrowSection boolValue];
	
	// prepare user info depending on the type
	NSDictionary *userInfo = nil;
	if (isTomorrow) {
		userInfo = @{ @"from": @"todayview", @"type": @"tomorrow" };
	} else {
		userInfo = @{ @"from": @"todayview" };
	}
	
	// dismiss notification center
	[[objc_getClass("SBNotificationCenterController") sharedInstance] dismissAnimated:YES];
	
	// present Calendar widget
	//[[PWController sharedInstance] presentWidgetNamed:@"Calendar" userInfo:userInfo];
	[PWWidgetController presentWidgetNamed:@"Calendar" userInfo:userInfo];
}

%end