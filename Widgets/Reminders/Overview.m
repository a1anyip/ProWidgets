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
	
	PWTheme *theme = self.theme;
	
	_noLabel = [UILabel new];
	_noLabel.text = @"Loading";
	_noLabel.textColor = [theme sheetForegroundColor];
	_noLabel.font = [UIFont boldSystemFontOfSize:22.0];
	_noLabel.textAlignment = NSTextAlignmentCenter;
	_noLabel.frame = self.view.bounds;
	_noLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:_noLabel];
}

- (NSString *)title {
	return @"All Reminders";
}

- (void)loadView {
	self.view = [[[PWThemableTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain theme:self.theme] autorelease];
}

- (UITableView *)tableView {
	return (UITableView *)self.view;
}

- (EKEventStore *)store {
	return [PWWidgetReminders widget].eventStore;
}

- (void)willBePresentedInNavigationController:(UINavigationController *)navigationController {
	[self loadReminders];
	[self setHandlerForEvent:[PWContentViewController titleTappedEventName] target:self selector:@selector(titleTapped)];
}

- (void)reload {
	
	// reload table view
	[self.tableView reloadData];
	
	// fade in or out the no label
	if ([_reminders count] == 0) {
		_noLabel.text = @"No Reminders";
		self.tableView.alwaysBounceVertical = NO;
		[UIView animateWithDuration:PWTransitionAnimationDuration animations:^{
			_noLabel.alpha = 1.0;
		}];
	} else {
		self.tableView.alwaysBounceVertical = YES;
		[UIView animateWithDuration:PWTransitionAnimationDuration animations:^{
			_noLabel.alpha = 0.0;
		}];
	}
}

- (void)titleTapped {
	[[PWWidgetReminders widget] switchToAddInterface];
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
		[self reload];
		applyFadeTransition(tableView, PWTransitionAnimationDuration);
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
		cell = [[[PWWidgetRemindersTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier theme:self.theme] autorelease];
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
		
		NSPredicate *predicate = [self.store predicateForIncompleteRemindersWithDueDateStarting:nil ending:nil calendars:nil];
		[self.store fetchRemindersMatchingPredicate:predicate completion:^(NSArray *reminders) {
			
			[_reminders release];
			_reminders = [reminders mutableCopy];
			
			LOG(@"Reminder list: %@", reminders);
			
			dispatch_sync(dispatch_get_main_queue(), ^{
				// reload table view
				[self reload];
				applyFadeTransition(self.tableView, PWTransitionAnimationDuration);
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
			[self reload];
			applyFadeTransition(self.tableView, PWTransitionAnimationDuration);
		}
	}
}

- (void)dealloc {
	RELEASE_VIEW(_noLabel)
	RELEASE(_reminders)
	[super dealloc];
}

@end