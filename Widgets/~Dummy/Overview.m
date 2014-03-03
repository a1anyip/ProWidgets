//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "Overview.h"
#import "Calendar.h"
#import "Cell.h"
#import "PWContentViewController.h"
#import "PWThemableTableView.h"

@implementation PWWidgetCalendarOverviewViewController

- (void)load {
	
	self.shouldAutoConfigureStandardButtons = NO;
	self.shouldMaximizeContentHeight = YES;
	
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
}

- (NSString *)title {
	return @"Upcoming Events";
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
}

- (void)titleTapped {
	PWWidgetCalendar *widget = (PWWidgetCalendar *)self.widget;
	[widget switchToAddInterface];
}

/**
 * UITableViewDelegate
 **/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 90.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	//unsigned int row = [indexPath row];
	
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
	//return [_events count];
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	//unsigned int row = [indexPath row];
	
	NSString *identifier = @"PWWidgetCalendarTableViewCell";
	PWWidgetCalendarTableViewCell *cell = (PWWidgetCalendarTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
	
	if (!cell) {
		cell = [[PWWidgetCalendarTableViewCell new] autorelease];
	}
	
	
	
	return cell;
}

- (void)retrieveCalendars {
	
	// retrieve all alarms via API
	//[_alarms release];
	//_alarms = [[PWAPIAlarmManager allAlarms] retain];
	
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

- (void)dealloc {
	[super dealloc];
}

@end