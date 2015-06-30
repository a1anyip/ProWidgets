//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "Reminders.h"
#import "Add.h"
#import "Overview.h"

#define localizedDateFormat(template) [NSDateFormatter dateFormatFromTemplate:template options:0 locale:[NSLocale currentLocale]]

@implementation PWWidgetReminders

// Short form: don't include date if there is day of week available
- (NSString *)parseDate:(NSDate *)date allDay:(BOOL)allDay shortForm:(BOOL)shortForm {
	
	NSInteger dayDifference = [self calculateDayDifference:[NSDate date] toDate:date];
	NSString *result = nil;
	
	// parse the date
	NSDateFormatter *dateFormat = self.dateFormatter;
	[dateFormat setLocale:[NSLocale currentLocale]];
	dateFormat.dateFormat = [NSString stringWithFormat:@"%@|%@|%@", localizedDateFormat(@"HH:mm"), localizedDateFormat(@"MMM d"), localizedDateFormat(@"ccc")];
	NSString *formattedDate = [dateFormat stringFromDate:date];
	
	// split the text into three different parts
	NSArray *formatttedDateParts = [formattedDate componentsSeparatedByString:@"|"];
	NSString *timeText = nil;
	NSString *dayText = nil;
	NSString *dayOfWeekText = nil;
	if ([formatttedDateParts count] == 3) {
		timeText = [formatttedDateParts objectAtIndex:0];
		dayText = [formatttedDateParts objectAtIndex:1];
		dayOfWeekText = [formatttedDateParts objectAtIndex:2];
	}
	
	if (dayDifference <= 1) {
		
		NSString *specialText = nil;
		if (dayDifference == 1)
			specialText = @"Tomorrow";
		else if (dayDifference == 0)
			specialText = @"Today";
		else if (dayDifference == -1)
			specialText = @"Yesterday";
		else
			specialText = [NSString stringWithFormat:@"%d days ago", abs(dayDifference)];
		
		result = [NSString stringWithFormat:@"%@%@%@",
				  specialText,
				  shortForm ? @"" : [NSString stringWithFormat:@", %@", dayText],
				  allDay ? @"" : [NSString stringWithFormat:@" %@", timeText]];
		
	} else if (dayDifference > 1 && dayDifference <= 6 + 7 /* include next week */) {
		
		result = [NSString stringWithFormat:@"%@%@%@%@",
				  dayDifference > 7 ? @"Next " : @"",
				  dayOfWeekText,
				  shortForm ? @"" : [NSString stringWithFormat:@", %@", dayText],
				  allDay ? @"" : [NSString stringWithFormat:@" %@", timeText]];
		
	} else {
		
		result = [NSString stringWithFormat:@"%@%@%@",
				  !shortForm ? [NSString stringWithFormat:@"%@ ", dayOfWeekText] : @"",
				  dayText,
				  allDay ? @"" : [NSString stringWithFormat:@" %@", timeText]];
	}
	
	return result == nil ? @"" : result;
}

- (NSUInteger)calculateDayDifference:(NSDate *)fromDate toDate:(NSDate *)toDate {
	
	NSCalendar* calendar = [NSCalendar currentCalendar];
	NSCalendarUnit units = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
	NSDateComponents *comp1 = [calendar components:units fromDate:fromDate];
	NSDateComponents *comp2 = [calendar components:units fromDate:toDate];
	[comp1 setHour:12];
	[comp2 setHour:12];
	NSDate *date1 = [calendar dateFromComponents:comp1];
	NSDate *date2 = [calendar dateFromComponents:comp2];
	return [[calendar components:NSDayCalendarUnit fromDate:date1 toDate:date2 options:0] day];
}

- (void)load {
	
	PWWidgetRemindersInterface defaultInterface = [self intValueForPreferenceKey:@"defaultInterface" defaultValue:0] == 1 ? PWWidgetRemindersInterfaceOverview : PWWidgetRemindersInterfaceAdd;
	
	if (defaultInterface == PWWidgetRemindersInterfaceAdd) {
		[self switchToAddInterface];
	} else {
		[self switchToOverviewInterface];
	}
}

- (EKEventStore *)eventStore {
	if (_eventStore == nil) _eventStore = [EKEventStore new];
	return _eventStore;
}

- (NSDateFormatter *)dateFormatter {
	if (_dateFormatter == nil) {
		_dateFormatter = [NSDateFormatter new];
		[_dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	}
	return _dateFormatter;
}

- (void)switchToAddInterface {
	
	if (_currentInterface == PWWidgetRemindersInterfaceAdd) return;
	
	if (_addViewControllers == nil) {
		PWWidgetRemindersAddViewController *addViewController = [[[PWWidgetRemindersAddViewController alloc] initForWidget:self] autorelease];
		_addViewControllers = [@[addViewController] copy];
	}
	
	[self setViewControllers:_addViewControllers animated:YES];
	_currentInterface = PWWidgetRemindersInterfaceAdd;
}

- (void)switchToOverviewInterface {
	
	if (_currentInterface == PWWidgetRemindersInterfaceOverview) return;
	
	if (_overviewViewControllers == nil) {
		PWWidgetRemindersOverviewViewController *overviewViewController = [[[PWWidgetRemindersOverviewViewController alloc] initForWidget:self] autorelease];
		_overviewViewControllers = [@[overviewViewController] copy];
	}
	
	[self setViewControllers:_overviewViewControllers animated:YES];
	_currentInterface = PWWidgetRemindersInterfaceOverview;
}

- (void)dealloc {
	RELEASE(_eventStore)
	RELEASE(_dateFormatter)
	RELEASE(_addViewControllers)
	RELEASE(_overviewViewControllers)
	[super dealloc];
}

@end