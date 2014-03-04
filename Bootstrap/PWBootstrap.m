//
//  ProWidgets
//  Bootstrap (inject the library into SpringBoard)
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"
#import "PWController.h"
#import "PWWebRequest.h"
#import "preference/PWPrefURLInstallation.h"

#define IS_PROWIDGETS(x) [[x scheme] isEqualToString:@"prowidgets"]

extern CFNotificationCenterRef CFNotificationCenterGetDistributedCenter();

static void handleException(NSException *exception) {
	NSArray *symbols = [exception callStackSymbols];
	NSLog(@"***** ProWidgets Uncaught Exception: %@ *****", [exception description]);
	unsigned i = 0;
	for (i = 0; i < [symbols count]; i++) {
		NSLog(@"***** %@", (NSString *)[symbols objectAtIndex:i]);
	}
}

@interface UITextEffectsWindow : UIWindow
@end

%group SpringBoard

// This is to fix the weird window level of keyboard
%hook UITextEffectsWindow

- (void)setWindowLevel:(CGFloat)windowLevel {
	if ([[PWController sharedInstance] isPresenting])
		%orig([(UIWindow *)[PWController sharedInstance].window windowLevel] + 1.0);
	else
		%orig;
}

/*
- (int)interfaceOrientation {
	LOG(@"interfaceOrientation: %d", %orig);
	return %orig;
}

- (void)updateForOrientation:(int)arg1 forceResetTransform:(BOOL)arg2 {
	%log;
	%orig;
}

- (void)updateForOrientation:(int)arg1 {
	%log;
	%orig;
}
*/

%end

%hook SBBacklightController

- (void)_lockScreenDimTimerFired {
	BOOL disabled = [PWController _shouldDisableLockScreenIdleTimer];
	if (disabled) {
		[self resetLockScreenIdleTimer];
	} else {
		%orig;
	}
}

%end

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
	
	LOG(@"PWBootstrap: Initializing PWController");
	
	PWController *instance = [PWController sharedInstance];
	
	// configure PWController
	[instance configure];
	
	// add observer
	[self addActiveOrientationObserver:instance];

	return %orig;
}

- (void)applicationOpenURL:(NSURL *)url withApplication:(id)application sender:(id)sender publicURLsOnly:(BOOL)only animating:(BOOL)animating needsPermission:(BOOL)permission additionalActivationFlags:(id)flags activationHandler:(id)handler {
	
	if (IS_PROWIDGETS(url)) {
		
		NSString *callURL = [url absoluteString];
		
		LOG(@"PWBootstrap: Received open URL notification (%@).", callURL);
		
		if (callURL != nil && [callURL length] > 0) {
			
			NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^prowidgets://install/(widget|theme)\\?url=(.+)$"
																				   options:0
																					 error:nil];
			
			NSTextCheckingResult *match = [regex firstMatchInString:callURL
															options:0
															  range:NSMakeRange(0, [callURL length])];
			
			if (match == nil) return;
			
			NSString *installType = nil;
			NSString *installURL = nil;
			for (unsigned int i = 0; i < [match numberOfRanges] - 1; i++) {
				
				NSRange range = [match rangeAtIndex:i + 1];
				if (range.location == NSNotFound) continue;
				
				NSString *part = [callURL substringWithRange:range];
				
				if (i == 0) {
					installType = part;
				} else if (i == 1) {
					installURL = [PWWebRequest decodeURIComponent:part];
				}
			}
			
			if (installType != nil && installURL != nil && [installURL length] > 0) {
				NSString *constructedURL = [NSString stringWithFormat:@"prefs:root=cc.tweak.prowidgets&install=%@&url=%@", installType, installURL];
				LOG(@"PWBootstrap: Opening '%@'", constructedURL);
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:constructedURL]];
			}
		}
	} else {
		%orig;
	}
}

%end

%end

%group Preferences

%hook TKTonePicker

- (id)initWithFrame:(CGRect)arg1 avController:(id)arg2 filter:(unsigned int)arg3 tonePicker:(BOOL)arg4 {
	LOG(@"### TKTonePicker ### filter: %d, tonePicker: %@", (int)arg3, arg4 ? @"YES" : @"NO");
	return %orig;
}

%end

%hook PreferencesAppController

- (void)applicationOpenURL:(NSURL *)url {
	
	%orig;
	
	NSString *string = [url absoluteString];
	if ([string hasPrefix:@"prefs:root=cc.tweak.prowidgets"]) {
		
		BOOL installWidget = [string rangeOfString:@"&install=widget&"].location != NSNotFound;
		BOOL installTheme = !installWidget && [string rangeOfString:@"&install=theme&"].location != NSNotFound;
		
		if (installWidget || installTheme) {
			
			// locate the position of url parameter
			NSUInteger urlIndex = [string rangeOfString:@"&url="].location;
			if (urlIndex == NSNotFound) return;
			
			// extract the installation URL
			NSString *urlString = [string substringFromIndex:urlIndex + 5];
			
			if ([urlString length] > 0) {
				
				// create installation URL
				NSURL *installURL = [NSURL URLWithString:urlString];
				
				// retrieve root view controller
				UIViewController *rootViewController = [[UIApplication sharedApplication].keyWindow rootViewController];
				
				// create installation view controller
				PWPrefURLInstallation *controller = [[[objc_getClass("PWPrefURLInstallation") alloc] initWithURL:installURL type:(installWidget ? PWPrefURLInstallationTypeWidget : PWPrefURLInstallationTypeTheme) fromPreference:NO] autorelease];
				
				// present it
				[rootViewController presentViewController:controller animated:NO completion:nil];
			}
		}
	}
}

%end

%end

static inline __attribute__((constructor)) void init() {
	@autoreleasepool {
		NSSetUncaughtExceptionHandler(&handleException);
		if (objc_getClass("SpringBoard") != nil) {
			%init(SpringBoard);
		} else if (objc_getClass("PreferencesAppController") != nil) {
			%init(Preferences);
		}
	}
}