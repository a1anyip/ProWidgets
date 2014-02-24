//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"

@interface PWWidgetCalendar : PWWidget {
	
	EKEventStore *_eventStore;
	
	PWWidgetCalendarInterface _currentInterface;
	NSArray *_addViewControllers;
	NSArray *_overviewViewControllers;
}

@property(nonatomic, readonly) EKEventStore *eventStore;

- (void)switchToAddInterface;
- (void)switchToOverviewInterface;

@end