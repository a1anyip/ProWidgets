//
//  ProWidgets
//  Substrate (mainly to inject the library into SpringBoard)
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"

#import "PWWidgetPickerCell.h"

#import "PWController.h"
#import "PWWidgetController.h"
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
/*
// This is to fix the weird window level of keyboard
%hook UITextEffectsWindow

- (void)setWindowLevel:(CGFloat)windowLevel {
	if ([PWWidgetController isPresentingWidget])
		%orig([(UIWindow *)[PWController sharedInstance].window windowLevel] + 1.0);
	else
		%orig;
}

%end
*/
%hook SBBacklightController

- (void)_lockScreenDimTimerFired {
	if ([PWWidgetController isLocked]) {
		[self resetLockScreenIdleTimer];
	} else {
		%orig;
	}
}

%end

%hook SBNotificationCenterController

- (void)beginPresentationWithTouchLocation:(CGPoint)touchLocation {
	if ([PWWidgetController isPresentingMaximizedWidget]) {
		[PWWidgetController minimizeAllControllers];
	}
	%orig;
}

%end

%hook SBControlCenterController

- (void)beginTransitionWithTouchLocation:(CGPoint)touchLocation {
	if ([PWWidgetController isPresentingMaximizedWidget]) {
		[PWWidgetController minimizeAllControllers];
	}
	%orig;
}

%end

%hook SpringBoard

-(void)_handleMenuButtonEvent {
	LOG(@"PWSubstrate: _handleMenuButtonEvent");
	NSTimer *menuButtonTimer = *(NSTimer **)instanceVar(self, "_menuButtonTimer");
	if (menuButtonTimer == nil) {
		PWWidgetController *activeController = [PWWidgetController activeController];
		if (activeController != nil && [activeController dismiss]) {
			// reset menuButtonClickCount
			Ivar ivar = class_getInstanceVariable([self class], "_menuButtonClickCount");
			uintptr_t *_menuButtonClickCount = (uintptr_t *)((char *)self + ivar_getOffset(ivar));
			*_menuButtonClickCount = 0;
			return;
		}
	}
	
	%orig;
}

- (void)handleMenuDoubleTap {
	if (![PWWidgetController isPresentingMaximizedWidget]) {
		%orig;
	}
}

- (void)applicationDidFinishLaunching:(id)application {
	
	LOG(@"PWSubstrate: Initializing PWController");
	
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
		
		LOG(@"PWSubstrate: Received open URL notification (%@).", callURL);
		
		if (callURL != nil && [callURL length] > 0) {
			
			if ([callURL hasPrefix:@"prowidgets://present?name="]) {
				
				NSString *widgetName = [callURL substringFromIndex:[@"prowidgets://present?name=" length]];
				widgetName = [PWWebRequest decodeURIComponent:widgetName];
				
				if (widgetName != nil && [widgetName length] > 0) {
					NSDictionary *userInfo = @{ @"from": @"url" };
					[PWWidgetController presentWidgetNamed:widgetName userInfo:userInfo];
				}
				
			} else if ([callURL hasPrefix:@"prowidgets://install/"]) {
				
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
					LOG(@"PWSubstrate: Opening '%@'", constructedURL);
					[PWWidgetController minimizeAllControllers];
					[[UIApplication sharedApplication] openURL:[NSURL URLWithString:constructedURL]];
				}
			}
		}
	} else {
		// minimize all controllers when a URL is being opened
		[PWWidgetController minimizeAllControllers];
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

#define CellClass PWWidgetPickerCell
#define CellTypeString @"PWWidgetPickerCell"
#define DetailString @"PWWidgetPicker"

%hook PSTableCell

+ (Class)cellClassForSpecifier:(PSSpecifier *)specifier {
	NSString *cell = [specifier propertyForKey:@"cell"];
	if ([cell isEqualToString:CellTypeString]) {
		return [PWWidgetPickerCell class];
	} else {
		return %orig;
	}
}

+ (NSString *)reuseIdentifierForSpecifier:(PSSpecifier *)specifier {
	NSString *cell = [specifier propertyForKey:@"cell"];
	if ([cell isEqualToString:CellTypeString]) {
		return CellTypeString;
	} else {
		return %orig;
	}
}

+ (int)cellTypeFromString:(NSString *)string {
	if ([string isEqualToString:CellTypeString]) {
		return 2;
	} else {
		return %orig;
	}
}

%end

@interface PSSpecifier ()

- (void)_pw_prepareWidgetInfo;

@end

static char PWPreparedWidgetInfoKey;

#define PREPARE NSNumber *o = objc_getAssociatedObject(self, &PWPreparedWidgetInfoKey); if (o == NULL || o == nil || ![o boolValue]) [self _pw_prepareWidgetInfo];
#define SET_PREPARED objc_setAssociatedObject(self, &PWPreparedWidgetInfoKey, @(1), OBJC_ASSOCIATION_COPY_NONATOMIC);

%hook PSSpecifier

- (NSArray *)titleDictionary {
	PREPARE;
	return %orig;
}

- (NSArray *)values {
	PREPARE;
	return %orig;
}

%new
- (void)_pw_prepareWidgetInfo {
	NSString *cell = [self propertyForKey:@"cell"];
	if ([cell isEqualToString:CellTypeString]) {
		
		NSMutableArray *titles = [NSMutableArray array];
		NSMutableArray *values = [NSMutableArray array];
		
		// PWShowNone
		NSNumber *_showNone = [self propertyForKey:@"PWShowNone"];
		BOOL showNone = _showNone == nil || ![_showNone isKindOfClass:[NSNumber class]] ? YES : [_showNone boolValue];
		
		if (showNone) {
			[titles addObject:@"None"];
			[values addObject:@""];
		}
		
		// retrieve widget list
		NSArray *list = [[PWController sharedInstance] enabledWidgets];
		for (NSDictionary *widget in list) {
			NSString *name = widget[@"name"];
			NSString *displayName = widget[@"displayName"];
			[titles addObject:displayName];
			[values addObject:name];
		}
		
		[self setValues:values titles:titles shortTitles:nil usingLocalizedTitleSorting:NO];
	}
	SET_PREPARED;
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