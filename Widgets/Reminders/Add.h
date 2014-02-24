//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"

@interface PWWidgetRemindersAddViewController : PWContentItemViewController {
	
	NSArray *_lists;
	NSMutableArray *_dayReminderSettings;
}

- (void)fetchLists:(NSString *)selectedIdentifier;
- (void)setInitialAlarmDate;

- (void)hideDayReminder;
- (void)showDayReminder;

@end