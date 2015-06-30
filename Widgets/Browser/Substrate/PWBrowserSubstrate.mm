//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"
#import "function.h"
#import "interface.h"
#import "PWController.h"
#import "PWWidgetController.h"
#import <objcipc/IPC.h>

#define PREF_PATH @"/var/mobile/Library/Preferences/cc.tweak.prowidgets.widget.browser.plist"
#define SCHEME_ENABLED(scheme) ((enabledOpenInAppSafari && [scheme hasPrefix:@"http"]) || (enabledOpenInAppChrome && [scheme hasPrefix:@"googlechrome"]))

@interface UIWebClip : NSObject

- (NSURL *)pageURL;

@end

@interface SBBookmarkIcon : NSObject

- (UIWebClip *)webClip;

@end

static BOOL enabledOpenInAppSafari = NO;
static BOOL enabledOpenInAppChrome = NO;
static BOOL enabledOpenFromIcon = NO;
static BOOL enabledAddToBookmark = NO;

static inline BOOL openBrowserWithURL(NSURL *url, NSString *from) {
	if (url == nil || from == nil) return NO;
	NSDictionary *userInfo = @{ @"from": from, @"url": url };
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

%hook UIApplication

- (BOOL)openURL:(NSURL *)url {
	
	BOOL result = %orig;
	
	if (SCHEME_ENABLED(url.scheme)) {
		return YES;
	} else {
		return result;
	}
}

%end

%hook UIActionSheet

- (void)addButtonWithTitle:(NSString *)title {
	%orig(ReplaceReadingListTitle(title));
}

%end

static inline BOOL handleAddReadingListItem(NSURL *url, NSString *title) {
	
	LOG(@"handleAddReadingListItem: %@", [url absoluteString]);
	
	if (enabledAddToBookmark) {
		
		if (url != nil) {
			NSDictionary *userInfo = @{
									   @"from": @"addBookmark",
									   @"title": (title == nil ? @"" : title),
									   @"url": url
									   };
			PWPresentWidget(@"Browser", userInfo);
		}
		
		return YES;
		
	} else {
		
		return NO;
	}
}

// for public use
%hook SSReadingList

- (BOOL)addReadingListItemWithURL:(NSURL *)url title:(NSString *)title previewText:(id)arg3 error:(id *)arg4 {
	if (handleAddReadingListItem(url, title)) return YES;
	else return %orig;
}

%end

// for internal use
%hook WBReadingList

- (BOOL)addReadingListItemWithURL:(NSURL *)url title:(NSString *)title previewText:(id)arg3 error:(id*)arg4 {
	if (handleAddReadingListItem(url, title)) return YES;
	else return %orig;
}

%end

%end

%group SpringBoard

static inline NSString *decodeURIComponent(NSString *string) {
	
	NSMutableString *resultString = [NSMutableString stringWithString:string];
	[resultString replaceOccurrencesOfString:@"+"
								  withString:@" "
									 options:NSLiteralSearch
									   range:NSMakeRange(0, [resultString length])];
	
	return [[[resultString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] copy] autorelease];
}

static inline BOOL handleSBOpenURL(NSURL *url) {
	
	LOG(@"handleSBOpenURL: %@", url);
	
	// a much more reliable way to determine where the URL is opened from
	BOOL fromWidget = [url isKindOfClass:objc_getClass("PWURL")];
	if (!fromWidget && url != nil) {
		NSString *scheme = [[url scheme] lowercaseString];
		if (SCHEME_ENABLED(scheme)) {
			
			// replace the googlechrome scheme to http
			if ([scheme hasPrefix:@"googlechrome"]) {
				if ([scheme isEqualToString:@"googlechrome-x-callback"]) {
					
					NSString *query = url.query;
					NSString *encodedURLString = nil;
					
					for (NSString *param in [query componentsSeparatedByString:@"&"]) {
						NSArray *parts = [param componentsSeparatedByString:@"="];
						if([parts count] < 2) continue;
						if ([parts[0] isEqualToString:@"url"]) {
							encodedURLString = parts[1];
							break;
						}
					}
					
					if (encodedURLString != nil && [encodedURLString length] > 0) {
						NSString *decodedURLString = decodeURIComponent(encodedURLString);
						url = [NSURL URLWithString:decodedURLString];
					} else {
						// cannot parse the URL / empty address
						return YES;
					}
					
				} else {
					NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
					components.scheme = [scheme hasSuffix:@"s"] ? @"https" : @"http";
					url = components.URL;
				}
			}
			
			openBrowserWithURL(url, @"app");
			
			return YES;
		}
	}
	
	return NO;
}

%hook SpringBoard

// 7.0
//- (void)_applicationOpenURL:(NSURL *)url withApplication:(id)application sender:(id)sender publicURLsOnly:(BOOL)only animating:(BOOL)animating additionalActivationFlags:(id)flags activationHandler:(id)handler {
- (void)_openURLCore:(NSURL *)url display:(id)display animating:(BOOL)animating sender:(id)sender additionalActivationFlags:(id)flags activationHandler:(id)handler {
    if (!handleSBOpenURL(url)) {
        %orig;
    }
}

// 7.1
//- (void)_applicationOpenURL:(NSURL *)url withApplication:(id)application sender:(id)sender publicURLsOnly:(BOOL)only animating:(BOOL)animating activationContext:(id)context activationHandler:(id)handler {
- (void)_openURLCore:(NSURL *)url display:(id)display animating:(BOOL)animating sender:(id)sender activationContext:(id)context activationHandler:(id)handler {
    if (!handleSBOpenURL(url)) {
        %orig;
    }
}

%end

%hook SBBookmark

- (BOOL)icon:(SBBookmarkIcon *)icon launchFromLocation:(int)location {
	
	if (enabledOpenFromIcon) {
		UIWebClip *webClip = icon.webClip;
		NSURL *url = webClip.pageURL;
		return openBrowserWithURL(url, @"icon");
	}
	
	return %orig;
}

%end

%end

// Loading preference
static inline void loadPref() {
	
	NSDictionary *pref = [[NSDictionary alloc] initWithContentsOfFile:PREF_PATH];
	
#define PREF_BOOL(x,y) NSNumber *_##x = pref[@#x];\
	x = _##x == nil || ![_##x isKindOfClass:[NSNumber class]] ? y : [_##x boolValue];
	
	PREF_BOOL(enabledOpenInAppSafari, YES)
	PREF_BOOL(enabledOpenInAppChrome, YES)
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
	
	/*
	if (objc_getClass("BookmarkInteractionControllerImpl") != nil) {
		%init(Chrome)
	}*/
	
	%init(App)
}