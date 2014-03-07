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
	
	PWTheme *theme = self.theme;
	
	_noLabel = [UILabel new];
	_noLabel.text = @"Loading";
	_noLabel.textColor = [PWTheme translucentColor:[theme sheetForegroundColor]];
	_noLabel.font = [UIFont boldSystemFontOfSize:22.0];
	_noLabel.textAlignment = NSTextAlignmentCenter;
	_noLabel.frame = self.view.bounds;
	_noLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:_noLabel];
}

- (NSString *)title {
	return @"Manage";
}

- (void)loadView {
	self.view = [[[PWThemableTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain theme:self.theme] autorelease];
}

- (UITableView *)tableView {
	return (UITableView *)self.view;
}

- (void)willBePresentedInNavigationController:(UINavigationController *)navigationController {
	[self configureCloseButton];
	[self retrieveAlarms];
	[self setHandlerForEvent:[PWContentViewController titleTappedEventName] target:self selector:@selector(titleTapped)];
}

- (void)reload {
	
	// reload table view
	[self.tableView reloadData];
	
	// fade in or out the no label
	if ([_alarms count] == 0) {
		_noLabel.text = @"No Alarms";
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
	[[PWWidgetAlarm widget] switchToAddInterface];
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
	
	if (row >= [_alarms count]) return;
	
	PWAPIAlarm *alarm = _alarms[row];
	[PWAPIAlarmManager removeAlarm:alarm];
	
	[self retrieveAlarms];
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
		cell = [[[PWWidgetAlarmTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier theme:self.theme] autorelease];
	}
	
	[cell setActive:alarm.active];
	[cell setHour:alarm.hour minute:alarm.minute];
	[cell setTitle:alarm.title daySetting:alarm.daySetting];
	
	return cell;
}

- (void)retrieveAlarms {
	
	dispatch_async(dispatch_get_global_queue(0, 0), ^{
		
		// retrieve all alarms via API
		[_alarms release];
		_alarms = [[PWAPIAlarmManager allAlarms] copy];
		
		dispatch_sync(dispatch_get_main_queue(), ^{
			// reload table view
			[self reload];
			applyFadeTransition(self.tableView, PWTransitionAnimationDuration);
		});
		
	});
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
	RELEASE_VIEW(_noLabel)
	RELEASE(_alarms)
	[super dealloc];
}

@end