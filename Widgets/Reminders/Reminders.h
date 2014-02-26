//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"

@interface PWWidgetReminders : PWWidget {
	
	EKEventStore *_eventStore;
	NSDateFormatter *_dateFormatter;
	
	PWWidgetRemindersInterface _currentInterface;
	NSArray *_addViewControllers;
	NSArray *_overviewViewControllers;
}

- (NSString *)parseDate:(NSDate *)date allDay:(BOOL)allDay shortForm:(BOOL)shortForm;
- (NSUInteger)calculateDayDifference:(NSDate *)fromDate toDate:(NSDate *)toDate;

- (EKEventStore *)eventStore;
- (NSDateFormatter *)dateFormatter;

- (void)switchToAddInterface;
- (void)switchToOverviewInterface;

@end