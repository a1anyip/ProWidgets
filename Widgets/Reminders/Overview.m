//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "Overview.h"
#import "Reminders.h"
#import "Cell.h"
#import "PWContentViewController.h"
#import "PWThemableTableView.h"

extern char PWWidgetRemindersTableViewCellReminderKey;

@implementation PWWidgetRemindersOverviewViewController

- (void)load {
	
	self.actionButtonText = @"More";
	
	self.shouldAutoConfigureStandardButtons = YES;
	self.shouldMaximizeContentHeight = YES;
	
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
}

- (NSString *)title {
	return @"All Reminders";
}

- (void)loadView {
	self.view = [[[PWThemableTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
}

- (UITableView *)tableView {
	return (UITableView *)self.view;
}

- (EKEventStore *)store {
	PWWidgetReminders *widget = (PWWidgetReminders *)[PWController activeWidget];
	return widget.eventStore;
}

- (void)willBePresentedInNavigationController:(UINavigationController *)navigationController {
	[self loadReminders];
	[self setHandlerForEvent:[PWContentViewController titleTappedEventName] target:self selector:@selector(titleTapped)];
}

- (void)titleTapped {
	PWWidgetReminders *widget = (PWWidgetReminders *)[PWController activeWidget];
	[widget switchToAddInterface];
}

/**
 * UITableViewDelegate
 **/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 50.0;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
	return @"Remove";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	unsigned int row = [indexPath row];
	
	if (row >= [_reminders count]) return;
	
	EKEventStore *store = self.store;
	EKReminder *reminder = _reminders[row];
	
	NSError *error = nil;
	if ([store removeReminder:reminder commit:YES error:&error]) {
		[_reminders removeObjectAtIndex:row];
		[tableView reloadData];
		applyFadeTransition(tableView, .3);
	}
}


//////////////////////////////////////////////////////////////////////

/**
 * UITableViewDataSource
 **/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [_reminders count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	unsigned int row = [indexPath row];
	
	NSString *identifier = @"PWWidgetRemindersTableViewCell";
	PWWidgetRemindersTableViewCell *cell = (PWWidgetRemindersTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
	
	if (!cell) {
		cell = [[[PWWidgetRemindersTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier] autorelease];
		[cell setButtonTarget:self action:@selector(buttonPressed:)];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	EKReminder *reminder = _reminders[row];
	
	// reminder title
	[cell setTitle:reminder.title];
	
	// reminder alarm
	NSArray *alarms = reminder.alarms;
	if ([alarms count] > 0) {
		
		NSDate *alarmDate = nil;
		EKRecurrenceRule *recurrenceRule = nil;
		
		// alarm date
		EKAlarm *alarm = alarms[0];
		alarmDate = alarm.absoluteDate;
		
		// repeat
		NSArray *recurrenceRules = reminder.recurrenceRules;
		if ([recurrenceRules count] > 0) {
			recurrenceRule = recurrenceRules[0];
		}
		
		[cell setAlarmDate:alarmDate recurrenceRule:recurrenceRule];
	}
	
	EKCalendar *calendar = reminder.calendar;
	CGColorRef color = calendar.CGColor;
	UIColor *colorUI = [UIColor colorWithCGColor:color];
	if (colorUI == nil) colorUI = [UIColor blackColor];
	[cell setListColor:colorUI];
	
	[cell setButtonReminder:reminder];
	
	return cell;
}

- (void)loadReminders {
	
	dispatch_async(dispatch_get_global_queue(0, 0), ^{
		
		NSPredicate *predicate = [self.store predicateForIncompleteRemindersWithDueDateStarting:nil ending:[NSDate distantFuture] calendars:nil];
		[self.store fetchRemindersMatchingPredicate:predicate completion:^(NSArray *reminders) {
			
			[_reminders release];
			_reminders = [reminders mutableCopy];
			
			LOG(@"Reminder list: %@", reminders);
			
			dispatch_sync(dispatch_get_main_queue(), ^{
				// reload table view
				[self.tableView reloadData];
				applyFadeTransition(self.tableView, .2);
			});
		}];
	});
}

- (void)buttonPressed:(UIButton *)button {
	EKReminder *reminder = objc_getAssociatedObject(button, &PWWidgetRemindersTableViewCellReminderKey);
	if (reminder != nil) {
		EKEventStore *store = self.store;
		reminder.completed = YES;
		if ([store saveReminder:reminder commit:YES error:nil]) {
			[_reminders removeObject:reminder];
			[self.tableView reloadData];
			applyFadeTransition(self.tableView, .3);
		}
	}
}

- (void)dealloc {
	RELEASE(_reminders)
	[super dealloc];
}

@end