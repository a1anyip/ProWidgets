//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "Overview.h"
#import "Alarm.h"
#import "Cell.h"
#import "PWContentViewController.h"
#import "PWThemableTableView.h"
#import "API/Alarm.h"

@implementation PWWidgetAlarmOverviewViewController

- (void)load {
	
	self.shouldAutoConfigureStandardButtons = NO;
	self.shouldMaximizeContentHeight = YES;
	
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
}

- (NSString *)title {
	return @"Manage";
}

- (void)loadView {
	self.view = [[[PWThemableTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
}

- (UITableView *)tableView {
	return (UITableView *)self.view;
}

- (void)willBePresentedInNavigationController:(UINavigationController *)navigationController {
	[self configureCloseButton];
	[self setHandlerForEvent:[PWContentViewController titleTappedEventName] target:self selector:@selector(titleTapped)];
	[self retrieveAlarms];
}

- (void)titleTapped {
	PWWidgetAlarm *widget = (PWWidgetAlarm *)[PWController activeWidget];
	[widget switchToAddInterface];
}

/**
 * UITableViewDelegate
 **/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 90.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	unsigned int row = [indexPath row];
	[self toggleActiveStateOfAlarmAtRow:row];
	
	// deselect the cell
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//////////////////////////////////////////////////////////////////////

/**
 * UITableViewDataSource
 **/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [_alarms count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	unsigned int row = [indexPath row];
	PWAPIAlarm *alarm = _alarms[row];
	
	NSString *identifier = @"PWWidgetAlarmTableViewCell";
	PWWidgetAlarmTableViewCell *cell = (PWWidgetAlarmTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
	
	if (!cell) {
		cell = [[[PWWidgetAlarmTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
	}
	
	[cell setActive:alarm.active];
	[cell setHour:alarm.hour minute:alarm.minute];
	[cell setTitle:alarm.title daySetting:alarm.daySetting];
	
	return cell;
}

- (void)retrieveAlarms {
	
	// retrieve all alarms via API
	[_alarms release];
	_alarms = [[PWAPIAlarmManager allAlarms] retain];
	
	// reload table view
	[self.tableView reloadData];
	
	// from http://stackoverflow.com/questions/7547934/animated-reloaddata-on-uitableview
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[animation setFillMode:kCAFillModeBoth];
	[animation setDuration:.2];
	[[self.tableView layer] addAnimation:animation forKey:@"fade"];
}

- (void)toggleActiveStateOfAlarmAtRow:(NSUInteger)row {
	
	if (row >= [_alarms count]) return;
	
	PWAPIAlarm *alarm = _alarms[row];
	BOOL originalActive = alarm.active;
	BOOL newActive = !originalActive;
	alarm.active = newActive;
	
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
	[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)dealloc {
	RELEASE(_alarms)
	[super dealloc];
}

@end