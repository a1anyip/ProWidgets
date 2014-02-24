//
//  ProWidgets
//  Activator Event (Trigger for Activator)
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"
#import "libactivator.h"
#import "PWController.h"

#define ICON_PATH @"/Library/PreferenceBundles/ProWidgets.bundle/icon@2x.png"

#define ListenerNameDismiss			@"ProWidgetsDismiss"
#define ListenerNamePrefix			@"ProWidgets:"
#define ListenerNameForWidget(x)	[NSString stringWithFormat:@"%@%@", ListenerNamePrefix, (x)]

@class LAProWidgets;

// function definitions
static inline void registerListener(NSString *name);
static inline NSString *widgetNameFromListenerName(NSString *listenerName);
static inline BOOL isDismissListenerName(NSString *listenerName);

// store shared instance
static LAProWidgets *sharedInstance = nil;

@interface LAProWidgets : NSObject<LAListener>

+ (instancetype)sharedInstance;

- (void)_registerDismissListener;
- (void)_registerWidgetListener;
- (UIImage *)_iconForWidgetNamed:(NSString *)name;

@end

@implementation LAProWidgets

+ (instancetype)sharedInstance {
	
	@synchronized(self) {
		if (sharedInstance == nil)
			[self new];
	}
	
	return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
	
	@synchronized(self) {
		if (sharedInstance == nil) {
			sharedInstance = [super allocWithZone:zone];
			LOG(@"LAProWidgets: allocated shared instance (%@)", sharedInstance);
			return sharedInstance;
		}
	}
	
	return nil;
}

- (instancetype)init {
	if ((self = [super init])) {
		
		if (objc_getClass("PWController") == nil) {
			LOG(@"ProWidgetsListener: 'PWController' not found");
			return self;
		}
		
		[self _registerDismissListener];
		[self _registerWidgetListener];
	}
	return self;
}

- (void)_registerDismissListener {
	registerListener(ListenerNameDismiss);
}

- (void)_registerWidgetListener {
	
	NSArray *installedWidgets = [[PWController sharedInstance] installedWidgets];
	
	for (NSDictionary *widget in installedWidgets) {
		NSString *name = ListenerNameForWidget(widget[@"name"]);
		BOOL enableActivation = [widget[@"enableActivation"] boolValue];
		if (enableActivation)
			registerListener(name);
		else
			LOG(@"ProWidgetsListener: Skipped widget (%@). Reason: Disabled activation", name);
	}
}

- (UIImage *)_iconForWidgetNamed:(NSString *)name {
	UIImage *icon = [[PWController sharedInstance] iconOfWidgetNamed:name];
	return icon != nil ? icon : [UIImage imageWithContentsOfFile:ICON_PATH];
}

//////////////////////////////////////////////////////////////////////

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event forListenerName:(NSString *)listenerName {
		
	LOG(@"ProWidgetsListener: Receive event (%@)", event);
	
	// retrieve the name of the widget
	NSString *widgetName = widgetNameFromListenerName(listenerName);
	
	// present the widget
	PWController *controller = [PWController sharedInstance];
	
	BOOL success = NO;
	
	if (isDismissListenerName(listenerName)) {
		success = [controller dismissWidget];
	} else {
		NSDictionary *userInfo = nil;
		if (event != nil) {
			userInfo = @{ @"from": @"activator", @"event": event };
		} else {
			userInfo = @{ @"from": @"activator" };
		}
		success = [controller presentWidgetNamed:widgetName userInfo:userInfo];
	}
	
	event.handled = success;
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event forListenerName:(NSString *)listenerName {
	
	LOG(@"ProWidgetsListener: Abort event (%@)", event);
}

//////////////////////////////////////////////////////////////////////

- (NSString *)activator:(LAActivator *)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName {
	
	if (isDismissListenerName(listenerName)) {
		return @"Dismiss";
	} else {
		NSString *name = widgetNameFromListenerName(listenerName);
		NSDictionary *info = [[PWController sharedInstance] infoOfWidgetNamed:name];
		return info[@"displayName"];
	}
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName {
	
	if (isDismissListenerName(listenerName)) {
		return @"Dismiss presented widget";
	} else {
		//NSString *widgetName = widgetNameFromListenerName(listenerName);
		//return [NSString stringWithFormat:@"Present widget '%@'", widgetName];
		return @"Present widget";
	}
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedGroupForListenerName:(NSString *)listenerName {
	return isDismissListenerName(listenerName) ? @"ProWidgets " : @"ProWidgets";
}

- (NSArray *)activator:(LAActivator *)activator requiresCompatibleEventModesForListenerWithName:(NSString *)listenerName {
	return @[@"springboard", @"application", @"lockscreen"];
}

- (UIImage *)activator:(LAActivator *)activator requiresIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale {
	return [self _iconForWidgetNamed:widgetNameFromListenerName(listenerName)];
}

- (UIImage *)activator:(LAActivator *)activator requiresSmallIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale {
	return [self _iconForWidgetNamed:widgetNameFromListenerName(listenerName)];
}

//////////////////////////////////////////////////////////////////////

- (id)copyWithZone:(NSZone *)zone { return self; }
- (id)retain { return self; }
- (oneway void)release {}
- (id)autorelease { return self; }
- (NSUInteger)retainCount { return NSUIntegerMax; }

@end

static inline void registerListener(NSString *name) {
	[[objc_getClass("LAActivator") sharedInstance] registerListener:[LAProWidgets sharedInstance] forName:name];
}

static inline NSString *widgetNameFromListenerName(NSString *listenerName) {
	
	static int prefixLength = -1;
	if (prefixLength == -1) prefixLength = [ListenerNamePrefix length];
	
	return [listenerName substringFromIndex:prefixLength];
}

static inline BOOL isDismissListenerName(NSString *listenerName) {
	return [listenerName isEqualToString:ListenerNameDismiss];
}

static inline __attribute__((constructor)) void init() {
	
	// initialize
	[LAProWidgets sharedInstance];
}