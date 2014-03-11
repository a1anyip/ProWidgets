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
	
	BOOL fromTodayView = [userInfo[@"from"] isEqualToString:@"todayview"];
	BOOL initialTomorrow = [userInfo[@"type"] isEqualToString:@"tomorrow"];
	
	if (fromTodayView) {
		[self switchToAddInterface];
		PWWidgetCalendarAddViewController *addViewController = (PWWidgetCalendarAddViewController *)_addViewControllers[0];
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