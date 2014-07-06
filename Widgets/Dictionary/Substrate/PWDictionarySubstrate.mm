//
//  ProWidgets
//
//  1.1.0
//
//  Created by Alan Yip on 5 Jul 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"
#import "interface.h"
#import "function.h"
#import "PWController.h"
#import "PWWidgetController.h"
#import <objcipc/IPC.h>

#define PREF_PATH @"/var/mobile/Library/Preferences/cc.tweak.prowidgets.widget.dictionary.plist"

static BOOL enabledOpenFromDefine = NO;

static inline BOOL openDictionary(NSString *term) {
	
	if (term == nil) return NO;
    
	NSDictionary *userInfo = @{
                               @"from": @"app",
                               @"term": term
                               };
    
    return PWPresentWidget(@"Dictionary", userInfo);
}

%group App

%hook _UITextServiceSession

+ (id)showServiceForText:(NSString *)text type:(int)type fromRect:(CGRect)rect inView:(id)inView {
	if (enabledOpenFromDefine && [text length] > 0) {
		openDictionary(text);
		return nil;
	} else {
		return %orig;
	}
}

%end

%end

// Loading preference
static inline void loadPref() {
	
	NSDictionary *pref = [[NSDictionary alloc] initWithContentsOfFile:PREF_PATH];
	
#define PREF_BOOL(x,y) NSNumber *_##x = pref[@#x];\
	x = _##x == nil || ![_##x isKindOfClass:[NSNumber class]] ? y : [_##x boolValue];
	
	PREF_BOOL(enabledOpenFromDefine, YES)
	
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
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &reloadPref, CFSTR("cc.tweak.prowidgets.widget.dictionary.preferencechanged"), NULL, 0);
	
	%init(App)
}