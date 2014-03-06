//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "Add.h"
#import "Reminders.h"

@implementation PWWidgetRemindersAddViewController

- (void)load {
	
	[self loadPlist:@"AddItems"];
	
	// fetch all available lists
	[self fetchLists:nil];
	
	// set the default alarm date value
	[self setInitialAlarmDate];
	
	// hide the day reminder section
	BOOL defaultShowDayReminder = [(NSNumber *)[self itemWithKey:@"dayReminderSwitch"].value boolValue];
	if (!defaultShowDayReminder)
		[self hideDayReminder];
	
	// set handler for pressing the Show More button
	[self setItemValueChangedEventHandler:self selector:@selector(itemValueChangedEventHandler:oldValue:)];
	[self setSubmitEventHandler:self selector:@selector(submitEventHandler:)];
	[self setHandlerForEvent:[PWContentViewController titleTappedEventName] target:self selector:@selector(titleTapped)];
	[self setHandlerForEvent:@"PWWidgetRemindersShowMoreSettings" target:self selector:@selector(showMoreSettings)];
}

- (void)titleTapped {
	[[PWWidgetReminders widget] switchToOverviewInterface];
}

- (EKEventStore *)store {
	return [PWWidgetReminders widget].eventStore;
}
- (void)fetchLists:(NSString *)selectedIdentifier {
	
	PWWidgetReminders *widget = (PWWidgetReminders *)self.widget;
	NSArray *lists = [self.store calendarsForEntityType:EKEntityTypeReminder];
	
	if ([lists count] == 0) {
		[widget showMessage:@"You need at least one list to save reminders."];
		[widget dismiss];
		return;
	}
	
	NSMutableArray *titles = [NSMutableArray array];
	NSMutableArray *values = [NSMutableArray array];
	
	NSUInteger selectedIndex = NSNotFound;
	unsigned int i = 0;
	for (EKCalendar *list in lists) {
		
		if (list.title == nil) {
			i++;
			continue;
		}
		
		if (selectedIdentifier != nil && [list.calendarIdentifier isEqualToString:selectedIdentifier]) {
			selectedIndex = i;
		}
		
		[titles addObject:list.title];
		[values addObject:@(i++)];
	}
	
	NSUInteger defaultIndex = NSNotFound;
	if (selectedIndex != NSNotFound) {
		defaultIndex = selectedIndex;
	} else {
		
		if (selectedIdentifier != nil) {
			// cannot locate the new calendar
			[widget showMessage:@"Unable to create list"];
		}
		
		EKCalendar *defaultList = [self.store defaultCalendarForNewReminders];
		defaultIndex = [lists indexOfObject:defaultList];
	}
	
	if (defaultIndex == NSNotFound) defaultIndex = 0;
	
	// add "Create..." option
	[titles addObject:@"Create..."];
	[values addObject:@(NSIntegerMax)];
	
	PWWidgetItemListValue *item = (PWWidgetItemListValue *)[self itemWithKey:@"list"];
	[item setListItemTitles:titles values:values];
	[item setValue:@(defaultIndex)];
	
	_lists = [lists retain];
	[lists release];
}

- (void)createList:(NSString *)name {
	
	if (name == nil || [name length] == 0) {
		name = @"Untitled";
	}
	
	PWWidgetReminders *widget = (PWWidgetReminders *)self.widget;
	EKCalendar *list = [EKCalendar calendarForEntityType:EKEntityTypeReminder eventStore:self.store];
	
	// retrieve preference
	int preferredSource = (int)[PWController sharedInstance].preferredSource;
	
	LOG(@"Reminder: retrieved source preference <value: %d>", preferredSource);
	
	// set calendar title
	list.title = name;
	
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
		list.source = calendarSource;
		
		// set new value in calendar item
		BOOL success = [self.store saveCalendar:list commit:YES error:NULL];
		if (success) {
			NSString *identifier = list.calendarIdentifier;
			[self fetchLists:identifier]; // refetch available calendars
			return;
		}
	}
	
	PWWidgetItemListValue *item = (PWWidgetItemListValue *)[self itemWithKey:@"list"];
	[widget showMessage:@"Unable to create list"];
	[item setValue:nil];
}

- (void)setInitialAlarmDate {
	
	NSTimeInterval nextHourTime = [[NSDate date] timeIntervalSinceReferenceDate] + 60 * 60;
	NSDate *nextHourDate = [NSDate dateWithTimeIntervalSinceReferenceDate:nextHourTime];
	
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *nextHourComp = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit) fromDate:nextHourDate];
	
	PWWidgetItemDateValue *alarm = (PWWidgetItemDateValue *)[self itemWithKey:@"alarm"];
	
	NSDate *alarmDate = [calendar dateFromComponents:nextHourComp];
	[alarm setValue:alarmDate];
}

- (void)hideDayReminder {
	
	if (_dayReminderSettings == nil) {
		
		_dayReminderSettings = [NSMutableArray new];
		
		NSArray *settingKeys = @[@"alarm", @"repeat"];
		
		for (NSString *key in settingKeys) {
			// retrieve the item constructed from plist
			PWWidgetItem *item = [self itemWithKey:key];
			if (item == nil) continue;
			// cache it
			[_dayReminderSettings addObject:item];
			// remove it from items
			[self removeItem:item animated:YES];
		}
		
	} else {
		
		for (PWWidgetItem *item in _dayReminderSettings) {
			// remove it from items
			[self removeItem:item animated:YES];
		}
	}
}

- (void)showDayReminder {
	// add back the cached items to widget
	[self addItems:_dayReminderSettings atIndex:2 animated:YES];
}

- (void)itemValueChangedEventHandler:(PWWidgetItem *)item oldValue:(id)oldValue {
	
	NSString *key = item.key;
	
	if ([key isEqualToString:@"dayReminderSwitch"]) {
		
		BOOL value = [(NSNumber *)item.value boolValue];
		if (value) {
			[self showDayReminder];
		} else {
			[self hideDayReminder];
		}
		
	} else if ([key isEqualToString:@"list"]) {
		
		NSArray *value = (NSArray *)item.value;
		if ([value count] == 1) {
			if ([value[0] isEqual:[[(PWWidgetItemListValue *)item listItemValues] lastObject]]) {
				
				__block NSArray *oldListValue = [oldValue retain];
				
				// Create...
				[self.widget prompt:@"Enter the list name" title:@"Create List" buttonTitle:@"Create" defaultValue:nil style:UIAlertViewStylePlainTextInput completion:^(BOOL cancelled, NSString *firstValue, NSString *secondValue) {
					
					if (cancelled) {
						// set to previous value
						[item setValue:oldListValue];
					} else {
						// create a list with input name (firstValue)
						[self createList:firstValue];
					}
					
					[oldListValue release], oldListValue = nil;
				}];
			}
		}
	}
}

- (void)submitEventHandler:(NSDictionary *)values {
	
	NSString *title = values[@"title"];
	BOOL dayReminderSwitch = [values[@"dayReminderSwitch"] boolValue];
	NSDate *alarm = values[@"alarm"];
	NSUInteger repeat = [(values[@"repeat"])[0] unsignedIntegerValue];
	NSUInteger selectedListIndex = [(values[@"list"])[0] unsignedIntegerValue];
	
	EKReminder *reminder = [EKReminder reminderWithEventStore:self.store];
	
	// list
	NSArray *lists = [self.store calendarsForEntityType:EKEntityTypeReminder];
	EKCalendar *list = selectedListIndex >= [lists count] ? [self.store defaultCalendarForNewReminders] : lists[selectedListIndex];
	reminder.calendar = list;
	
	// title
	// Replace with "Untitled" if there are only spaces
	if ([[title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0)
		title = @"Untitled";
	
	reminder.title = title;
	
	if (dayReminderSwitch && alarm != nil) {
		
		// alarm
		EKAlarm *_alarm = [EKAlarm alarmWithAbsoluteDate:alarm];
		[reminder addAlarm:_alarm];
		
		// we must also set the ending date of the reminder
		NSDateComponents *dueDate = [[NSCalendar currentCalendar] components:NSMinuteCalendarUnit | NSHourCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:alarm];
		reminder.dueDateComponents = dueDate;
		
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
			[reminder addRecurrenceRule:rule];
			[rule release];
		}
	}
	
	// save
	[self.store saveReminder:reminder commit:YES error:nil];
	
	// dismiss
	[self.widget dismiss];
}

- (void)dealloc {
	[_dayReminderSettings release], _dayReminderSettings = nil;
	[super dealloc];
}

@end