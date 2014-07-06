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

#define PREF_PATH @"/var/mobile/Library/Preferences/cc.tweak.prowidgets.widget.calendar.plist"

static BOOL enabledOpenFromCreateEvent = NO;

static inline BOOL openCalendar(NSString *title, NSDate *startDate, NSDate *endDate, BOOL allDay) {
	if (title == nil) return NO;
    
	NSDictionary *userInfo = @{
                               @"from": @"app",
                               @"title": title ?: @"",
                               @"startDate": startDate ?: [NSNull null],
                               @"endDate": endDate ?: [NSNull null],
                               @"allDay": @(allDay)
                               };
    
    return PWPresentWidget(@"Calendar", userInfo);
}

%group App

%hook DDActionController

- (void)performAction:(DDAction *)action {
    
    if (enabledOpenFromCreateEvent && [action isKindOfClass:objc_getClass("DDCreateEventAction")]) {
        
        NSDictionary *context = action.context;
        NSString *title = context[@"EventTitle"];
        void *result = action.result;
        
        if (result != NULL) {
            
            DDScannerResult *scannerResult = [DDScannerResult resultFromCoreResult:result];
            NSString *type = [scannerResult type];
            
            LOG(@"DDActionController: Scanner result (%@: <%p> %@)", type, scannerResult, scannerResult);
            
            NSDate *startDate = nil;
            NSDate *endDate = nil;
            BOOL allDay = NO;
            
            if ([type isEqualToString:@"DateTime"]) {
                
                startDate = [scannerResult dateFromReferenceDate:nil referenceTimezone:nil timezoneRef:nil allDayRef:&allDay];
                
            } else if ([type isEqualToString:@"TimeDuration"]) {
                
                [scannerResult extractStartDate:&startDate startTimezone:nil endDate:&endDate endTimezone:nil allDayRef:&allDay referenceDate:nil referenceTimezone:nil];
            }
            
            LOG(@"Scanner result: / %@ / %@ / %d", startDate, endDate, allDay);
            
            openCalendar(title, startDate, endDate, allDay);
        }
        
    } else {
        %orig;
    }
}

%end

%end

// Loading preference
static inline void loadPref() {
	
	NSDictionary *pref = [[NSDictionary alloc] initWithContentsOfFile:PREF_PATH];
	
#define PREF_BOOL(x,y) NSNumber *_##x = pref[@#x];\
	x = _##x == nil || ![_##x isKindOfClass:[NSNumber class]] ? y : [_##x boolValue];
	
	PREF_BOOL(enabledOpenFromCreateEvent, YES)
	
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
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &reloadPref, CFSTR("cc.tweak.prowidgets.widget.calendar.preferencechanged"), NULL, 0);
	
	%init(App)
}