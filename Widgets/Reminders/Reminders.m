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

@implementation PWWidgetReminders

- (void)load {
	
	[super load]; // load widget plist
	
	PWWidgetRemindersInterface defaultInterface = PWWidgetRemindersInterfaceAdd;
	
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
		PWWidgetRemindersAddViewController *addViewController = [PWWidgetRemindersAddViewController new];
		_addViewControllers = [@[addViewController] copy];
	}
	
	[self setViewControllers:_addViewControllers animated:YES];
	_currentInterface = PWWidgetRemindersInterfaceAdd;
}

- (void)switchToOverviewInterface {
	
	if (_currentInterface == PWWidgetRemindersInterfaceOverview) return;
	
	if (_overviewViewControllers == nil) {
		PWWidgetRemindersOverviewViewController *overviewViewController = [PWWidgetRemindersOverviewViewController new];
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