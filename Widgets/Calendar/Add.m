//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "Add.h"
#import "Calendar.h"

@implementation PWWidgetCalendarAddViewController

- (void)load {
	
	[self loadPlist:@"AddItems"];
	
	PWWidgetCalendar *widget = (PWWidgetCalendar *)self.widget;
	_initialTomorrow = [widget.userInfo[@"type"] isEqualToString:@"tomorrow"];
	
	// fetch all available calendars
	[self fetchCalendars:nil];
	
	// set the default start and end date values
	[self setInitialDates];
	
	// reset alert titles and values
	BOOL defaultAllDay = [(NSNumber *)[self itemWithKey:@"allDay"].value boolValue];
	[self resetAlert:defaultAllDay];
	
	// hide the extra settings by default
	[self hideMoreSettings];
	
	// set handler for pressing the Show More button
	[self setItemValueChangedEventHandler:self selector:@selector(itemValueChangedEventHandler:oldValue:)];
	[self setSubmitEventHandler:self selector:@selector(submitEventHandler:)];
	[self setHandlerForEvent:[PWContentViewController titleTappedEventName] target:self selector:@selector(titleTapped)];
	[self setHandlerForEvent:@"PWWidgetCalendarShowMoreSettings" target:self selector:@selector(showMoreSettings)];
}

- (void)titleTapped {
	PWWidgetCalendar *widget = (PWWidgetCalendar *)self.widget;
	[widget switchToOverviewInterface];
}

- (EKEventStore *)store {
	PWWidgetCalendar *widget = (PWWidgetCalendar *)self.widget;
	return widget.eventStore;
}

- (void)fetchCalendars:(NSString *)selectedIdentifier {
	
	NSArray *calendars = [self.store calendarsForEntityType:EKEntityTypeEvent];
	
	if ([calendars count] == 0) {
		[self.widget showMessage:@"You need at least one calendar to save events."];
		[self.widget dismiss];
		return;
	}
	
	NSMutableArray *titles = [NSMutableArray array];
	NSMutableArray *values = [NSMutableArray array];
	
	NSUInteger selectedIndex = NSNotFound;
	unsigned int i = 0;
	for (EKCalendar *calendar in calendars) {
		
		if (calendar.title == nil) {
			i++;
			continue;
		}
		
		if (selectedIdentifier != nil && [calendar.calendarIdentifier isEqualToString:selectedIdentifier]) {
			selectedIndex = i;
		}
		
		[titles addObject:calendar.title];
		[values addObject:@(i++)];
	}
	
	NSUInteger defaultIndex = NSNotFound;
	if (selectedIndex != NSNotFound) {
		defaultIndex = selectedIndex;
	} else {
		
		if (selectedIdentifier != nil) {
			// cannot locate the new calendar
			[self.widget showMessage:@"Unable to create calendar"];
		}
		
		EKCalendar *defaultCalendar = [self.store defaultCalendarForNewEvents];
		defaultIndex = [calendars indexOfObject:defaultCalendar];
	}
	
	if (defaultIndex == NSNotFound) defaultIndex = 0;
	
	// add "Create..." option
	[titles addObject:@"Create..."];
	[values addObject:@(NSIntegerMax)];
	
	PWWidgetItemListValue *item = (PWWidgetItemListValue *)[self itemWithKey:@"calendar"];
	[item setListItemTitles:titles values:values];
	[item setValue:@(defaultIndex)];
	
	_calendars = [calendars retain];
	[calendars release];
}

- (void)createCalendar:(NSString *)name {
	
	if (name == nil || [name length] == 0) {
		name = @"Untitled";
	}
	
	EKCalendar *calendar = [EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:self.store];
	
	// retrieve preference
	int preferredSource = (int)[PWController sharedInstance].preferredSource; // iCloud by default
	
	LOG(@"Calendar: retrieved preferred source <value: %d>", (int)preferredSource);
	
	// set calendar title
	calendar.title = name;
	
	EKSource *calendarSource = nil;
	EKSource *_iCloudSource = nil;
	EKSource *_localSource = nil;
	for (EKSource *source in self.store.sources) {
		if (_iCloudSource == nil && source.sourceType == EKSourceTypeCalDAV && [source.title isEqualToString:@"iCloud"]) {
			// iCloud source
			_iCloudSource = source;
		} else if (_localSource == nil && source.sourceType == EKSourceTypeLocal) {
			// local source
			_localSource = source;
		}
	}
	
	calendarSource = (preferredSource == 0) ? _iCloudSource : _localSource;
	
	// fallback
	if (calendarSource == nil)
		calendarSource = (preferredSource == 0) ? _localSource : _iCloudSource;
	
	// no available source (rare)
	if (calendarSource != nil) {
		
		// set calendar source
		calendar.source = calendarSource;
		
		// set new value in calendar item
		BOOL success = [self.store saveCalendar:calendar commit:YES error:NULL];
		if (success) {
			NSString *identifier = calendar.calendarIdentifier;
			[self fetchCalendars:identifier]; // refetch available calendars
			return;
		}
	}
	
	PWWidgetItemListValue *item = (PWWidgetItemListValue *)[self itemWithKey:@"calendar"];
	[self.widget showMessage:@"Unable to create calendar"];
	[item setValue:nil];
}

- (void)setInitialDates {
	
	NSTimeInterval extraDayTime = _initialTomorrow ? 24 * 60 * 60 : 0;
	
	NSTimeInterval nextHourTime = [[NSDate date] timeIntervalSinceReferenceDate] + 60 * 60 + extraDayTime;
	NSTimeInterval nextTwoHoursTime = nextHourTime + 60 * 60;
	NSDate *nextHourDate = [NSDate dateWithTimeIntervalSinceReferenceDate:nextHourTime];
	NSDate *nextTwoHoursDate = [NSDate dateWithTimeIntervalSinceReferenceDate:nextTwoHoursTime];
	
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *nextHourComp = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit) fromDate:nextHourDate];
	NSDateComponents *nextTwoHoursComp = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit) fromDate:nextTwoHoursDate];
	
	PWWidgetItemDateValue *starts = (PWWidgetItemDateValue *)[self itemWithKey:@"starts"];
	PWWidgetItemDateValue *ends = (PWWidgetItemDateValue *)[self itemWithKey:@"ends"];
	
	NSDate *startDate = [calendar dateFromComponents:nextHourComp];
	NSDate *endDate = [calendar dateFromComponents:nextTwoHoursComp];
	
	[starts setValue:startDate];
	[ends setValue:endDate];
	
	[self updateDateTextVisibility];
}

- (void)resetAlert:(BOOL)isAllDay {
	
	NSArray *titles = nil;
	NSArray *values = nil;
	
	if (isAllDay) {
		
		titles = @[@"None",
				   @"On day of event (9 am)",
				   @"1 day before (9 am)",
				   @"2 days before (9 am)",
				   @"1 week before"];
		
		values = @[@(NSIntegerMax),
				   @(9 * 60 * 60),
				   @(-(1 * 24 - 9) * 60 * 60),
				   @(-(2 * 24 - 9) * 60 * 60),
				   @(-(7 * 24 - 9) * 60 * 60)];
	} else {
		
		titles = @[@"None",
				   @"At time of event",
				   @"5 minutes before",
				   @"15 minutes before",
				   @"30 minutes before",
				   @"1 hour before",
				   @"2 hours before",
				   @"1 day before",
				   @"2 days before",
				   @"1 week before"];
		
		values = @[@(NSIntegerMax),
				   @(0),
				   @(-5 * 60),
				   @(-15 * 60),
				   @(-30 * 60),
				   @(-1 * 60 * 60),
				   @(-2 * 60 * 60),
				   @(-1 * 24 * 60 * 60),
				   @(-2 * 24 * 60 * 60),
				   @(-7 * 24 * 60 * 60)];
	}
	
	PWWidgetItemListValue *alerts = (PWWidgetItemListValue *)[self itemWithKey:@"alerts"];
	[alerts setListItemTitles:titles values:values];
	[alerts setValue:@(NSIntegerMax)]; // reset to "None" default value
}

- (void)hideMoreSettings {
	
	if (_moreSettings != nil) {
		// more settings can only be shown once (after pressing more button)
		return;
	}
	
	_moreSettings = [NSMutableArray new];
	
	NSArray *settingKeys = @[@"allDay", @"repeat", @"alerts", @"calendar"];
	
	for (NSString *key in settingKeys) {
		// retrieve the item constructed from plist
		PWWidgetItem *item = [self itemWithKey:key];
		if (item == nil) continue; // prevent exceptions
		// cache it
		[_moreSettings addObject:item];
		// remove it from items
		[self removeItem:item animated:NO];
	}
}

- (void)showMoreSettings {
	
	// remove more button
	[self removeItem:[self itemWithKey:@"moreButton"] animated:YES];
	
	// add back the cached items to widget one by one
	[self addItems:_moreSettings animated:YES];
	
	[_moreSettings release], _moreSettings = nil;
}

- (void)itemValueChangedEventHandler:(PWWidgetItem *)item oldValue:(id)oldValue {
	
	NSString *key = item.key;
	
	if ([key isEqualToString:@"allDay"]) {
		
		// reset alert titles and values when All-day value changes
		BOOL isAllDay = [(NSNumber *)item.value boolValue];
		[self resetAlert:isAllDay];
		
		// set the date type of starts and ends
		PWWidgetItemDateValue *starts = (PWWidgetItemDateValue *)[self itemWithKey:@"starts"];
		PWWidgetItemDateValue *ends = (PWWidgetItemDateValue *)[self itemWithKey:@"ends"];
		
		if (isAllDay) {
			ends.hideDateText = NO;
			starts.datePickerMode = UIDatePickerModeDate;
			ends.datePickerMode = UIDatePickerModeDate;
		} else {
			[self updateDateTextVisibility];
			starts.datePickerMode = UIDatePickerModeDateAndTime;
			ends.datePickerMode = UIDatePickerModeDateAndTime;
		}
		
	} else if ([key isEqualToString:@"starts"]) {
		
		PWWidgetItemDateValue *ends = (PWWidgetItemDateValue *)[self itemWithKey:@"ends"];
		NSDate *oldStartDate = (NSDate *)oldValue;
		NSDate *startDate = (NSDate *)item.value;
		NSDate *endDate = (NSDate *)ends.value;
		
		// auto adjust the ends date
		if ([oldStartDate compare:endDate] != NSOrderedDescending) {
			NSCalendar *calendar = [NSCalendar currentCalendar];
			NSDateComponents *comp = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit
												 fromDate:oldStartDate // from
												   toDate:startDate // to
												  options:0];
			
			// apply the difference to end date as well
			NSDate *newEndDate = [calendar dateByAddingComponents:comp toDate:endDate options:0];
			[ends setValue:newEndDate];
		}
		
		[self updateDateTextVisibility];
		
	} else if ([key isEqualToString:@"ends"]) {
		
		[self updateDateTextVisibility];
		
	} else if ([key isEqualToString:@"calendar"]) {
		
		NSArray *value = (NSArray *)item.value;
		if ([value count] == 1) {
			if ([value[0] isEqual:[[(PWWidgetItemListValue *)item listItemValues] lastObject]]) {
				
				__block NSArray *oldCalendarValue = (NSArray *)[oldValue copy];
				
				// Create...
				[self.widget prompt:@"Enter the calendar name" title:@"Create Calendar" buttonTitle:@"Create" defaultValue:nil style:UIAlertViewStylePlainTextInput completion:^(BOOL cancelled, NSString *firstValue, NSString *secondValue) {
					
					if (cancelled) {
						// set to previous value
						[item setValue:oldCalendarValue];
					} else {
						// create a calendar with input name (firstValue)
						[self createCalendar:firstValue];
					}
					
					[oldCalendarValue release], oldCalendarValue = nil;
				}];
			}
		}
	}
}

- (void)updateDateTextVisibility {
	
	PWWidgetItemDateValue *allDay = (PWWidgetItemDateValue *)[self itemWithKey:@"allDay"];
	PWWidgetItemDateValue *starts = (PWWidgetItemDateValue *)[self itemWithKey:@"starts"];
	PWWidgetItemDateValue *ends = (PWWidgetItemDateValue *)[self itemWithKey:@"ends"];
	
	BOOL isAllDay = [(NSNumber *)allDay.value boolValue];
	
	if (isAllDay) {
		ends.hideDateText = NO;
	} else {
		
		// compare if the start and end day are in same day
		NSCalendar* calendar = [NSCalendar currentCalendar];
		
		unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
		NSDateComponents *startsComp = [calendar components:unitFlags fromDate:(NSDate *)starts.value];
		NSDateComponents *endsComp = [calendar components:unitFlags fromDate:(NSDate *)ends.value];
		
		if ([startsComp day] == [endsComp day] &&
			[startsComp month] == [endsComp month] &&
			[startsComp year] == [endsComp year]) {
			ends.hideDateText = YES;
		} else {
			ends.hideDateText = NO;
		}
	}
}

- (void)submitEventHandler:(NSDictionary *)values {
	
	NSString *title = values[@"title"];
	NSString *location = values[@"location"];
	BOOL allDay = [values[@"allDay"] boolValue];
	NSDate *starts = values[@"starts"];
	NSDate *ends = values[@"ends"];
	NSUInteger repeat = [(values[@"repeat"])[0] unsignedIntegerValue];
	NSArray *alerts = values[@"alerts"];
	NSUInteger selectedCalendarIndex = [(values[@"calendar"])[0] unsignedIntegerValue];
	
	if ([starts compare:ends] == NSOrderedDescending) {
		[self.widget showMessage:@"The start date must be before the end date." title:@"Cannot Save Event"];
		return;
	}
	
	EKEvent *event = [EKEvent eventWithEventStore:self.store];
	
	// calendar
	NSArray *calendars = [self.store calendarsForEntityType:EKEntityTypeEvent];
	EKCalendar *calendar = selectedCalendarIndex >= [calendars count] ? [self.store defaultCalendarForNewEvents] : calendars[selectedCalendarIndex];
	event.calendar = calendar;
	
	// title and location
	// Replace with "Untitled" if there are only spaces
	if ([[title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0)
		title = @"New Event";
	
	event.title = title;
	event.location = location;
	
	// starts and ends
	event.allDay = allDay;
	event.startDate = starts;
	event.endDate = ends;
	
	// recurrence
	if (repeat > 0 && repeat <= 5) { // within valid range
		
		EKRecurrenceFrequency frequency;
		int interval = 1;
		
		switch (repeat) {
			case 1: // Every Day
				frequency = EKRecurrenceFrequencyDaily;
				break;
			case 2: // Every Week
				frequency = EKRecurrenceFrequencyWeekly;
				break;
			case 3: // Every 2 Weeks
				frequency = EKRecurrenceFrequencyWeekly;
				interval = 2;
				break;
			case 4: // Every Month
				frequency = EKRecurrenceFrequencyMonthly;
				break;
			case 5: // Every Year
				frequency = EKRecurrenceFrequencyYearly;
				break;
		}
		
		EKRecurrenceRule *rule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:frequency interval:interval end:nil];
		[event addRecurrenceRule:rule];
		[rule release];
	}
	
	// alert
	if ([alerts count] > 0) {
		for (NSNumber *alert in alerts) {
			NSInteger offset = [alert integerValue];
			[event addAlarm:[EKAlarm alarmWithRelativeOffset:offset]];
		}
	}
	
	// save
	[self.store saveEvent:event span:EKSpanFutureEvents error:nil];
	
	// dismiss
	[self.widget dismiss];
}

- (void)dealloc {
	[_moreSettings release], _moreSettings = nil;
	[super dealloc];
}

@end