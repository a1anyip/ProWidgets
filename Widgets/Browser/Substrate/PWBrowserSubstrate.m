//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"
#import "interface.h"
#import "PWController.h"
#import "PWWidgetController.h"
#import <objcipc/IPC.h>

#define PREF_PATH @"/var/mobile/Library/Preferences/cc.tweak.prowidgets.widget.browser.plist"

@interface UIWebClip : NSObject

- (NSURL *)pageURL;

@end

@interface SBBookmarkIcon : NSObject

- (UIWebClip *)webClip;

@end

static BOOL enabledOpenInApp = NO;
static BOOL enabledOpenFromIcon = NO;
static BOOL enabledAddToBookmark = NO;

static inline BOOL openBrowserWithURL(NSString *url, NSString *from) {
	if (url == nil) return NO;
	NSDictionary *userInfo = @{ @"from": @"app", @"url": url };
	return [objc_getClass("PWWidgetController") presentWidgetNamed:@"Browser" userInfo:userInfo];
}

static inline NSString *ReplaceReadingListTitle(NSString *title) {
	
	if (enabledAddToBookmark) {
		if ([title isEqualToString:@"Add to Reading List"]) {
			return @"Bookmark";
		}
	}
	
	return title;
}

%group App

%hook UIActionSheet

- (void)addButtonWithTitle:(NSString *)title {
	%orig(ReplaceReadingListTitle(title));
}

%end

%hook SSReadingList

- (void)_addReadingListItemWithURL:(NSURL *)url title:(NSString *)title previewText:(NSString *)previewText {
	%log;
	//%orig;
	NSString *urlString = [url absoluteString];
	if (urlString != nil) {
		dispatch_sync(dispatch_get_main_queue(), ^{
			
			NSDictionary *userInfo = @{ @"from": @"addBookmark", @"title": (title == nil ? @"" : title), @"url": urlString };
			
			if (objc_getClass("SpringBoard") != nil) {
				[objc_getClass("PWWidgetController") presentWidgetNamed:@"Browser" userInfo:userInfo];
			} else {
				[objc_getClass("OBJCIPC") sendMessageToSpringBoardWithMessageName:@"prowidgets.presentwidget" dictionary:@{ @"name": @"Browser", @"userInfo":userInfo } replyHandler:nil];
			}
		});
	}
}

%end

%end

%group SpringBoard

%hook SpringBoard

- (void)applicationOpenURL:(NSURL *)url withApplication:(id)application sender:(id)sender publicURLsOnly:(BOOL)only animating:(BOOL)animating needsPermission:(BOOL)permission additionalActivationFlags:(id)flags activationHandler:(id)handler {
	
	// restore to original URL
	BOOL fromWidget = NO;
	NSString *urlString = url.absoluteString;
	if ([urlString hasSuffix:@"***PWBROWSERWIDGET"]) {
		fromWidget = YES;
		urlString = [urlString substringToIndex:[urlString length] - [@"***PWBROWSERWIDGET" length]];
		url = [NSURL URLWithString:urlString];
	}
	
	if (enabledOpenInApp && !fromWidget) {
		NSString *scheme = [[url scheme] lowercaseString];
		if (([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]) && urlString != nil) {
			openBrowserWithURL(urlString, @"app");
			return;
		}
	}
	
	%orig;
}

%end

%hook SBBookmark

- (BOOL)icon:(SBBookmarkIcon *)icon launchFromLocation:(int)location {
	
	if (enabledOpenFromIcon) {
		UIWebClip *webClip = icon.webClip;
		NSURL *url = webClip.pageURL;
		NSString *urlString = [url absoluteString];
		return openBrowserWithURL(urlString, @"icon");
	}
	
	return %orig;
}

%end

%end

// Loading preference
static inline void loadPref() {
	
	NSDictionary *pref = [[NSDictionary alloc] initWithContentsOfFile:PREF_PATH];
	
#define PREF_BOOL(x,y) NSNumber *_##x = pref[@"x"];\
	x = _##x == nil || ![_##x isKindOfClass:[NSNumber class]] ? y : [_##x boolValue];
	
	PREF_BOOL(enabledOpenInApp, YES)
	PREF_BOOL(enabledOpenFromIcon, YES)
	PREF_BOOL(enabledAddToBookmark, YES)
	
#undef PREF_BOOL
	
	[pref release];
}

static inline void reloadPref(CFNotificationCenterRef center,
							  void *observer,
							  CFStringRef name,
							  const void *object,
							  CFDictionaryRef userInfo) {
	loadPref();
}

static __attribute__((constructor)) void init() {
	
	// load preferences
	loadPref();
	
	// distributed notification center
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &reloadPref, CFSTR("cc.tweak.prowidgets.widget.browser.preferencechanged"), NULL, 0);
	
	if (objc_getClass("SpringBoard") != nil) {
		%init(SpringBoard)
	}
	
	%init(App)
}