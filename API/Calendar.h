//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "../header.h"
#import "../JSBridge/PWJSBridgeWrapper.h"
#import <EventKit/EventKit.h>

@protocol PWAPICalendarWrapperExport <JSExport>

- (NSString *)addCalendar:(JSValue *)title;
- (NSString *)addList:(JSValue *)title;

- (void)addEvent:(JSValue *)title :(JSValue *)location :(JSValue *)starts :(JSValue *)ends :(JSValue *)allDay :(JSValue *)calendar;

- (void)addReminder:(JSValue *)title :(JSValue *)alarmDate :(JSValue *)list;

@end

@interface PWAPICalendarWrapper : PWJSBridgeWrapper <PWAPICalendarWrapperExport> {
	
	EKEventStore *_store;
}

- (NSString *)_addCalendar:(EKEntityType)type title:(NSString *)title;

@end