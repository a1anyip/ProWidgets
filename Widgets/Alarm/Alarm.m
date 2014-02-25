//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "Alarm.h"
#import "Add.h"
#import "Overview.h"

@implementation PWWidgetAlarm

+ (NSUInteger)valuesToDateMask:(NSArray *)values {
	// convert repeat values to day setting (bitmask)
	NSUInteger daySetting = 0;
	for (NSNumber *value in values) {
		NSUInteger valueBitMask = [value unsignedIntegerValue];
		daySetting = daySetting | valueBitMask;
	}
	return daySetting;
}

- (BOOL)requiresProtectedDataAccess {
	return YES;
}

- (void)load {
	
	[super load]; // load widget plist
	
	PWWidgetAlarmInterface defaultInterface = PWWidgetAlarmInterfaceAdd;
	
	if (defaultInterface == PWWidgetAlarmInterfaceAdd) {
		[self switchToAddInterface];
	} else {
		[self switchToOverviewInterface];
	}
}

- (void)switchToAddInterface {
	
	if (_currentInterface == PWWidgetAlarmInterfaceAdd) return;
	
	if (_addViewControllers == nil) {
		PWWidgetAlarmAddViewController *addViewController = [PWWidgetAlarmAddViewController new];
		_addViewControllers = [@[addViewController] copy];
	}
	
	[self setViewControllers:_addViewControllers animated:YES];
	_currentInterface = PWWidgetAlarmInterfaceAdd;
}

- (void)switchToOverviewInterface {
	
	if (_currentInterface == PWWidgetAlarmInterfaceOverview) return;
	
	if (_overviewViewControllers == nil) {
		PWWidgetAlarmOverviewViewController *overviewViewController = [PWWidgetAlarmOverviewViewController new];
		_overviewViewControllers = [@[overviewViewController] copy];
	}
	
	[self setViewControllers:_overviewViewControllers animated:YES];
	_currentInterface = PWWidgetAlarmInterfaceOverview;
}

- (void)dealloc {
	RELEASE(_addViewControllers)
	RELEASE(_overviewViewControllers)
	[super dealloc];
}

@end