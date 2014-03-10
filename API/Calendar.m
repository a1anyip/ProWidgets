//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "Calendar.h"
#import "../PWController.h"
#import "../JSBridge/PWJSBridgeWrapper.h"

@implementation PWAPICalendarWrapper

- (instancetype)init {
	if ((self = [super init])) {
		_store = [EKEventStore new];
	}
	return self;
}

- (NSString *)addCalendar:(JSValue *)title {
	
	if ([title isUndefined]) {
		[_bridge throwException:@"addCalendar: requires argument 1 (title)"];
		return nil;
	}
	
	return [self _addCalendar:EKEntityTypeEvent title:[title toString]];
}

- (NSString *)addList:(JSValue *)title {
	
	if ([title isUndefined]) {
		[_bridge throwException:@"addList: requires argument 1 (title)"];
		return nil;
	}
	
	return [self _addCalendar:EKEntityTypeReminder title:[title toString]];
}

- (void)addEvent:(JSValue *)title :(JSValue *)location :(JSValue *)starts :(JSValue *)ends :(JSValue *)allDay :(JSValue *)calendar {
	
	if ([title isUndefined] || [location isUndefined] || [starts isUndefined] || [ends isUndefined]) {
		[_bridge throwException:@"addEvent: requires the first 4 arguments (title, location, starts and ends)"];
		return;
	}
	
	NSString *_title = [title isNull] ? @"" : [title toString];
	NSString *_location = [title isNull] ? @"" : [location toString];
	NSDate *_starts = [starts toDate];
	NSDate *_ends = [ends toDate];
	BOOL _allDay = [allDay isUndefined] ? NO : [allDay toBool];
	NSString *_calendar = [calendar isUndefined] || [calendar isNull] ? nil : [calendar toString];
	
	if ([_starts compare:_ends] == NSOrderedDescending) {
		[_bridge throwException:@"addEvent: the start date must be before the end date"];
		return;
	}
	
	EKEvent *event = [EKEvent eventWithEventStore:_store];
	
	// calendar
	EKCalendar *preferredCalendar = _calendar == nil ? nil : [_store calendarWithIdentifier:_calendar];
	preferredCalendar = preferredCalendar != nil ? preferredCalendar : [_store defaultCalendarForNewEvents];
	event.calendar = preferredCalendar;
	
	// title and location
	// Replace with "Untitled" if there are only spaces
	if ([[_title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0)
		_title = @"New Event";
	
	event.title = _title;
	event.location = _location;
	
	// starts and ends
	event.allDay = _allDay;
	event.startDate = _starts;
	event.endDate = _ends;
	
	// save
	[_store saveEvent:event span:EKSpanFutureEvents error:nil];
}

- (void)addReminder:(JSValue *)title :(JSValue *)alarmDate :(JSValue *)list {
	
	if ([title isUndefined]) {
		[_bridge throwException:@"addReminder: requires argument 1 (title)"];
		return;
	}
	
	NSString *_title = [title isNull] ? @"" : [title toString];
	NSDate *_alarmDate = [alarmDate isUndefined] || [alarmDate isNull] ? nil : [alarmDate toDate];
	NSString *_list = [list isUndefined] || [list isNull] ? nil : [list toString];
	
	EKReminder *reminder = [EKReminder reminderWithEventStore:_store];
	
	// title
	// Replace with "Untitled" if there are only spaces
	if ([[_title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0)
		_title = @"Untitled";
	
	reminder.title = _title;
	
	if (_alarmDate != nil) {
		
		// remove second part
		NSTimeInterval time = floor([_alarmDate timeIntervalSinceReferenceDate] / 60.0) * 60.0;
		NSDate *dateWithoutZero = [NSDate dateWithTimeIntervalSinceReferenceDate:time];
		
		EKAlarm *alarm = [EKAlarm alarmWithAbsoluteDate:dateWithoutZero];
		[reminder addAlarm:alarm];
		
		// we must also set the ending date of the reminder
		NSDateComponents *dueDate = [[NSCalendar currentCalendar] components:NSMinuteCalendarUnit | NSHourCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:dateWithoutZero];
		reminder.dueDateComponents = dueDate;
	}
	
	// calendar
	EKCalendar *preferredList = [_store calendarWithIdentifier:_list];
	preferredList = preferredList != nil ? preferredList : [_store defaultCalendarForNewReminders];
	reminder.calendar = preferredList;
		
	// save
	[_store saveReminder:reminder commit:YES error:nil];
}

- (NSString *)_addCalendar:(EKEntityType)type title:(NSString *)title {
	
	EKCalendar *calendar = [EKCalendar calendarForEntityType:type eventStore:_store];
	
	int sourcePreference = 0; // TODO
	
	// set calendar title
	calendar.title = title;
	
	EKSource *calendarSource = nil;
	EKSource *_iCloudSource = nil;
	EKSource *_localSource = nil;
	for (EKSource *source in _store.sources) {
		if (_iCloudSource == nil && source.sourceType == EKSourceTypeCalDAV && [source.title isEqualToString:@"iCloud"]) {
			// iCloud source
			_iCloudSource = source;
		} else if (_localSource == nil && source.sourceType == EKSourceTypeLocal) {
			// local source
			_localSource = source;
		}
	}
	
	calendarSource = (sourcePreference == 0) ? _iCloudSource : _localSource;
	
	// fallback
	if (calendarSource == nil)
		calendarSource = (sourcePreference == 0) ? _localSource : _iCloudSource;
	
	// no available source (rare)
	if (calendarSource != nil) {
		
		// set calendar source
		calendar.source = calendarSource;
		
		// set new value in calendar item
		BOOL success = [_store saveCalendar:calendar commit:YES error:NULL];
		if (success) {
			NSString *identifier = calendar.calendarIdentifier;
			return identifier;
		}
	}
	
	return @"";
}

- (void)dealloc {
	RELEASE(_store)
	[super dealloc];
}

@end