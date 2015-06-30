//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "Calendar.h"
#import "Add.h"
#import "Overview.h"

@implementation PWWidgetCalendar

- (void)load {
	
	PWWidgetCalendarInterface defaultInterface = [self intValueForPreferenceKey:@"defaultInterface" defaultValue:0] == 1 ? PWWidgetCalendarInterfaceOverview : PWWidgetCalendarInterfaceAdd;
	
	if (defaultInterface == PWWidgetCalendarInterfaceAdd) {
		[self switchToAddInterface];
	} else {
		[self switchToOverviewInterface];
	}
}

- (void)userInfoChanged:(NSDictionary *)userInfo {
	
    BOOL fromApp = [userInfo[@"from"] isEqualToString:@"app"];
	BOOL fromTodayView = [userInfo[@"from"] isEqualToString:@"todayview"];
	
    PWWidgetCalendarAddViewController *addViewController = nil;
    if (fromApp || fromTodayView) {
        [self switchToAddInterface];
		addViewController = (PWWidgetCalendarAddViewController *)_addViewControllers[0];
    }
    
    if (fromApp) {
        
        NSString *title = userInfo[@"title"];
        NSDate *startDate = userInfo[@"startDate"];
        NSDate *endDate = userInfo[@"endDate"];
        NSNumber *allDay = userInfo[@"allDay"];
		
#define checkNull(x) if ([x isKindOfClass:[NSNull class]]) x = nil;
		
		checkNull(title);
		checkNull(startDate);
		checkNull(endDate);
		checkNull(allDay);
		
#undef checkNull
		
		// automatically set the end date to one hour later than the start date
		if (startDate != nil && endDate == nil) {
			
			NSTimeInterval nextHourTime = [startDate timeIntervalSinceReferenceDate] + 60 * 60;
			NSDate *nextHourDate = [NSDate dateWithTimeIntervalSinceReferenceDate:nextHourTime];
			
			NSCalendar *calendar = [NSCalendar currentCalendar];
			NSDateComponents *nextHourComp = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit) fromDate:nextHourDate];
			
			endDate = [calendar dateFromComponents:nextHourComp];
		}
        
        // set values
        [addViewController itemWithKey:@"title"].value = title;
		
		if (startDate != nil) {
			[addViewController itemWithKey:@"starts"].value = startDate;
			[addViewController itemWithKey:@"ends"].value = endDate;
		} else {
			[addViewController setInitialDates];
		}
		
        [addViewController itemWithKey:@"allDay"].value = allDay;
        
        // reset all other fields
        [addViewController itemWithKey:@"location"].value = nil;
        [addViewController itemWithKey:@"repeat"].value = nil;
		[addViewController itemWithKey:@"alerts"].value = nil;
		[addViewController fetchCalendars:nil];
        
    } else if (fromTodayView) {
        
        BOOL initialTomorrow = [userInfo[@"type"] isEqualToString:@"tomorrow"];
		if (initialTomorrow) {
			[addViewController setInitialDates];
		}
        
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
	
	if (_currentInterface == PWWidgetCalendarInterfaceAdd) return;
	
	if (_addViewControllers == nil) {
		PWWidgetCalendarAddViewController *addViewController = [[[PWWidgetCalendarAddViewController alloc] initForWidget:self] autorelease];
		_addViewControllers = [@[addViewController] copy];
	}
	
	[self setViewControllers:_addViewControllers animated:YES];
	_currentInterface = PWWidgetCalendarInterfaceAdd;
}

- (void)switchToOverviewInterface {
	
	if (_currentInterface == PWWidgetCalendarInterfaceOverview) return;
	
	if (_overviewViewControllers == nil) {
		PWWidgetCalendarOverviewViewController *overviewViewController = [[[PWWidgetCalendarOverviewViewController alloc] initForWidget:self] autorelease];
		_overviewViewControllers = [@[overviewViewController] copy];
	}
	
	[self setViewControllers:_overviewViewControllers animated:YES];
	_currentInterface = PWWidgetCalendarInterfaceOverview;
}

- (void)dealloc {
	RELEASE(_eventStore)
	RELEASE(_dateFormatter)
	RELEASE(_addViewControllers)
	RELEASE(_overviewViewControllers)
	[super dealloc];
}

@end