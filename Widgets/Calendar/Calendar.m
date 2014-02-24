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
	
	[super load]; // load widget plist
	
	PWWidgetCalendarInterface defaultInterface = PWWidgetCalendarInterfaceAdd;
	
	if (defaultInterface == PWWidgetCalendarInterfaceAdd) {
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
	
	if (_currentInterface == PWWidgetCalendarInterfaceAdd) return;
	
	if (_addViewControllers == nil) {
		PWWidgetCalendarAddViewController *addViewController = [PWWidgetCalendarAddViewController new];
		_addViewControllers = [@[addViewController] copy];
	}
	
	[self setViewControllers:_addViewControllers animated:YES];
	_currentInterface = PWWidgetCalendarInterfaceAdd;
}

- (void)switchToOverviewInterface {
	
	if (_currentInterface == PWWidgetCalendarInterfaceOverview) return;
	
	if (_overviewViewControllers == nil) {
		PWWidgetCalendarOverviewViewController *overviewViewController = [PWWidgetCalendarOverviewViewController new];
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