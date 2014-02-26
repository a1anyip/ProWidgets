//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "Notes.h"
#import "Add.h"
#import "List.h"

@implementation PWWidgetNotes

// Short form: don't include date if there is day of week available
- (NSString *)parseDate:(NSDate *)date {
	
	NSInteger dayDifference = [self calculateDayDifference:[NSDate date] toDate:date];
	
	NSString *result = nil;
	NSDateFormatter *dateFormatter = self.dateFormatter;
	
	// reset
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	[dateFormatter setDateFormat:nil];
	
	if (dayDifference < -7) {
		// before last week
		// show date
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
		[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	} else if (dayDifference >= -7 && dayDifference < 0) {
		// last week
		// show day of week (e.g. Monday, Tuesday)
		[dateFormatter setDateFormat:@"EEEE"];
	} else {
		// today
		// show time
		[dateFormatter setDateStyle:NSDateFormatterNoStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	}
	
	result = [dateFormatter stringFromDate:date];
	
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
	
	PWWidgetNotesInterface defaultInterface = PWWidgetNotesInterfaceAdd;
	
	if (defaultInterface == PWWidgetNotesInterfaceAdd) {
		[self switchToAddInterface];
	} else {
		[self switchToListInterface];
	}
}

- (NoteContext *)noteContext {
	if (_noteContext == nil) {
		_noteContext = [objc_getClass("NoteContext") new];
		[_noteContext enableChangeLogging:YES]; // enable iCloud syncronization support
	}
	return _noteContext;
}

- (NSDateFormatter *)dateFormatter {
	if (_dateFormatter == nil) {
		_dateFormatter = [NSDateFormatter new];
		[_dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	}
	return _dateFormatter;
}

- (void)switchToAddInterface {
	
	if (_currentInterface == PWWidgetNotesInterfaceAdd) return;
	
	if (_addViewControllers == nil) {
		PWWidgetNotesAddViewController *addViewController = [PWWidgetNotesAddViewController new];
		_addViewControllers = [@[addViewController] copy];
	}
	
	[self setViewControllers:_addViewControllers animated:YES];
	_currentInterface = PWWidgetNotesInterfaceAdd;
}

- (void)switchToListInterface {
	
	if (_currentInterface == PWWidgetNotesInterfaceList) return;
	
	if (_listViewControllers == nil) {
		PWWidgetNotesListViewController *listViewController = [PWWidgetNotesListViewController new];
		_listViewControllers = [@[listViewController] copy];
	}
	
	[self setViewControllers:_listViewControllers animated:YES];
	_currentInterface = PWWidgetNotesInterfaceList;
}

- (void)dealloc {
	RELEASE(_noteContext)
	RELEASE(_dateFormatter)
	RELEASE(_addViewControllers)
	RELEASE(_listViewControllers)
	[super dealloc];
}

@end