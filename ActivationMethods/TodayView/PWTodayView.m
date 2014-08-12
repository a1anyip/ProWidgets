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

#define TV_PREF_PATH @"/var/mobile/Library/Preferences/cc.tweak.prowidgets.activationmethod.todayview.plist"
#define NOTIFICATION_NAME @"cc.tweak.prowidgets.activationmethod.todayview.preferencechanged"

#define ANIMATION_DURATION 0.1
#define BTN_TAG 1001
#define BTN_INITIAL_ALPHA .3
#define BTN_PRESSED_ALPHA .8

//static SBBulletinViewController *bulletinViewController;
static BOOL enabled = YES;
static char PWTodayViewTomorrowSectionKey;
/*
%hook SBBulletinViewController

- (id)init {
	id instance = %orig;
	bulletinViewController = instance;
	return instance;
}

- (void)dealloc {
	if (bulletinViewController == self) {
		bulletinViewController = nil;
	}
	%orig;
}

%end
*/
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
	
	[btn addTarget:self action:@selector(_pw_pressed) forControlEvents:UIControlEventTouchUpInside];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NAME object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_pw_preferenceChanged) name:NOTIFICATION_NAME object:nil];
	
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NAME object:nil];
	%orig;
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

%new
- (void)updateVisibility {
	
	UIButton *btn = (UIButton *)[self viewWithTag:BTN_TAG];
	
	if (!enabled) {
		btn.hidden = YES;
		return;
	}
	
	if (btn != nil) {
		
		// determine whether the header view is for Calendar widget
		BOOL isCalendarWidget = NO;
		BOOL isTomorrowSection = NO;
		UITableView *tableView = self.tableView;
		NSInteger section = [tableView _sectionForHeaderView:self];
		
		// retrieve SBBulletinViewController
		SBBulletinViewController *controller = (SBBulletinViewController *)tableView.delegate;
		
		if (![controller isKindOfClass:objc_getClass("SBBulletinViewController")]) {
			// fix crash in LockInfo7
			controller = nil;
		}
		
//		SBBulletinViewController *controller = bulletinViewController;
		if (controller != nil && section != NSNotFound) {
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
- (void)_pw_pressed {
	
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
	[[objc_getClass("SBNotificationCenterController") sharedInstance] dismissAnimated:YES completion:^{
		// present Calendar widget
		[PWWidgetController presentWidgetNamed:@"Calendar" userInfo:userInfo];
	}];
}

%new
- (void)_pw_preferenceChanged {
	[self updateVisibility];
}

%end

// Loading preference
static inline void loadPref() {
	NSDictionary *pref = [[NSDictionary alloc] initWithContentsOfFile:TV_PREF_PATH];
	NSNumber *_enabled = pref[@"enabled"];
	enabled = _enabled == nil || ![_enabled isKindOfClass:[NSNumber class]] ? YES : [_enabled boolValue];
	[pref release];
}

static inline void reloadPref(CFNotificationCenterRef center,
							  void *observer,
							  CFStringRef name,
							  const void *object,
							  CFDictionaryRef userInfo) {
	// then, load preference
	loadPref();
	// emit notification
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME object:nil];
}

static __attribute__((constructor)) void init() {
	
	// load preferences
	loadPref();
	
	// distributed notification center
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &reloadPref, CFSTR("cc.tweak.prowidgets.activationmethod.todayview.preferencechanged"), NULL, 0);

}