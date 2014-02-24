//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"

@interface PWWidgetCalendarAddViewController : PWContentItemViewController {
	
	BOOL _initialTomorrow;
	EKEventStore *_store;
	NSArray *_calendars;
	NSMutableArray *_moreSettings;
}

- (EKEventStore *)store;

- (void)fetchCalendars:(NSString *)selectedIdentifier;
- (void)createCalendar:(NSString *)name;
- (void)setInitialDates;
- (void)resetAlert:(BOOL)isAllDay;

- (void)hideMoreSettings;
- (void)showMoreSettings;

- (void)updateDateTextVisibility;

@end