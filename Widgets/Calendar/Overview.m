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
	
	self.actionButtonText = @"More";
	
	self.shouldAutoConfigureStandardButtons = YES;
	self.shouldMaximizeContentHeight = YES;
	
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	
	PWTheme *theme = [PWController activeTheme];
	
	_noLabel = [UILabel new];
	_noLabel.text = @"No upcoming events";
	_noLabel.textColor = [theme cellPlainTextColor];
	_noLabel.font = [UIFont boldSystemFontOfSize:22.0];
	_noLabel.textAlignment = NSTextAlignmentCenter;
	_noLabel.frame = self.view.bounds;
	_noLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:_noLabel];
}

- (NSString *)title {
	return @"All Events";
}

- (void)loadView {
	self.view = [[[PWThemableTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
}

- (UITableView *)tableView {
	return (UITableView *)self.view;
}

- (EKEventStore *)store {
	PWWidgetCalendar *widget = (PWWidgetCalendar *)self.widget;
	return widget.eventStore;
}

- (void)willBePresentedInNavigationController:(UINavigationController *)navigationController {
	[self loadEvents];
	[self setHandlerForEvent:[PWContentViewController titleTappedEventName] target:self selector:@selector(titleTapped)];
}

- (void)reload {
	
	// reload table view
	[self.tableView reloadData];
	
	// fade in or out the no label
	if ([_events count] == 0) {
		self.tableView.alwaysBounceVertical = NO;
		[UIView animateWithDuration:.2 animations:^{
			_noLabel.alpha = 1.0;
		}];
	} else {
		self.tableView.alwaysBounceVertical = YES;
		[UIView animateWithDuration:.2 animations:^{
			_noLabel.alpha = 0.0;
		}];
	}
}

- (void)titleTapped {
	PWWidgetCalendar *widget = (PWWidgetCalendar *)self.widget;
	[widget switchToAddInterface];
}

/**
 * UITableViewDelegate
 **/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	unsigned int section = [indexPath section];
	unsigned int row = [indexPath row];
	
	// deselect the cell
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	EKEvent *event = _events[section][@"events"][row];
	NSString *identifier = [[event.eventIdentifier stringByReplacingOccurrencesOfString:@" " withString:@"%20"] stringByReplacingOccurrencesOfString:@":" withString:@"/"];
	NSString *urlString = [NSString stringWithFormat:@"x-apple-calevent://%@", identifier];
	NSURL *url = [NSURL URLWithString:urlString];
	SpringBoard *app = (SpringBoard *)[UIApplication sharedApplication];
	if ([app canOpenURL:url]) {
		[app openURL:url];
		[self.widget dismiss];
	}
}

//////////////////////////////////////////////////////////////////////

/**
 * UITableViewDataSource
 **/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [_events count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSDictionary *row = _events[section];
	NSArray *events = row[@"events"];
	return [events count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	NSDictionary *row = _events[section];
	NSDate *date = row[@"date"];
	if (date == nil) return nil;
	
	PWWidgetCalendar *widget = (PWWidgetCalendar *)self.widget;
	NSDateFormatter *dateFormatter = widget.dateFormatter;
	
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	NSString *dayText = [dateFormatter stringFromDate:date];
	
	[dateFormatter setDateFormat:@"EEE"];
	NSString *dayOfWeekText = [dateFormatter stringFromDate:date];
	
	return [NSString stringWithFormat:@"%@  %@", dayOfWeekText, dayText];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	unsigned int section = [indexPath section];
	unsigned int row = [indexPath row];
	
	NSString *identifier = @"PWWidgetCalendarTableViewCell";
	PWWidgetCalendarTableViewCell *cell = (PWWidgetCalendarTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
	
	if (!cell) {
		cell = [[[PWWidgetCalendarTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
	}
	
	EKEvent *event = _events[section][@"events"][row];
	
	[cell setTitle:event.title];
	[cell setLocation:event.location];
	[cell setStartDate:event.startDate endDate:event.endDate allDay:event.allDay];
	
	EKCalendar *calendar = event.calendar;
	CGColorRef color = calendar.CGColor;
	[cell setCalendarColor:[UIColor colorWithCGColor:color]];
	
	return cell;
}

- (void)loadEvents {
	
	dispatch_async(dispatch_get_global_queue(0, 0), ^{
		
		NSCalendar *calendar = [NSCalendar currentCalendar];
		
		// get the date for today (from 12am)
		NSDate *date = [NSDate date];
		NSDate *todayDate = [calendar dateFromComponents:[calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:date]];
		
		NSUInteger period = 7; // in days
		NSTimeInterval endTime = [todayDate timeIntervalSinceReferenceDate] + period * 24 * 60 * 60;
		NSDate *endDate = [NSDate dateWithTimeIntervalSinceReferenceDate:endTime];
		
		__block NSMutableArray *events = [NSMutableArray array];
		__block NSDate *currentDate = nil;
		__block NSMutableArray *currentDateArray = nil;
		NSPredicate *predicate = [self.store predicateForEventsWithStartDate:todayDate endDate:endDate calendars:nil];
		[self.store enumerateEventsMatchingPredicate:predicate usingBlock:^(EKEvent *event, BOOL *stop) {
			
			// start date contains time
			NSDate *startDate = event.startDate;
			
			// extract only day information from it
			NSDate *dateWithDayOnly = [calendar dateFromComponents:[calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:startDate]];
			
			if (dateWithDayOnly == nil) return; // just in case the start date is nil
			
			if (currentDate == nil || ![dateWithDayOnly isEqual:currentDate]) {
				
				// update current date
				currentDate = dateWithDayOnly;
				
				// create a new item
				NSMutableDictionary *day = [NSMutableDictionary dictionary];
				day[@"date"] = dateWithDayOnly;
				day[@"events"] = [NSMutableArray array];
				
				currentDateArray = day[@"events"];
				[events addObject:day];
			}
			
			// add the event to the array for its start day
			[currentDateArray addObject:event];
		}];
		
		currentDate = nil, currentDateArray = nil;
		
		// store the events
		[_events release];
		_events = [events retain];
		
		LOG(@"Event list: %@", events);
		
		dispatch_sync(dispatch_get_main_queue(), ^{
			// reload table view
			[self reload];
			applyFadeTransition(self.tableView, .2);
		});
	});
}

- (void)dealloc {
	RELEASE_VIEW(_noLabel)
	RELEASE(_events)
	[super dealloc];
}

@end