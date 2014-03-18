//
//  ProWidgets
//  Google Authenticator
//
//  Created by Alan Yip on 22 Feb 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "ViewController.h"
#import "PWTheme.h"
#import "Cell.h"
#import "PWController.h"
#import "PWTheme.h"
#import "PWWidget.h"
#import <objcipc/objcipc.h>

typedef enum {
	TimeBased = 1,
	CounterBased = 2
} RecordType;

@implementation PWWidgetGoogleAuthenticatorViewController

- (void)load {
	
	_firstTime = YES;
	
	self.requiresKeyboard = NO;
	self.shouldMaximizeContentHeight = NO;
	self.actionButtonText = @"Manage";
	
	self.view.backgroundColor = [PWTheme parseColorString:@"#d9d9d9"];
	
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.separatorInset = UIEdgeInsetsZero;
	
	// setup timer
	_timer = [[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerTick) userInfo:nil repeats:YES] retain];
}

- (NSString *)title {
	return @"Authenticator";
}

- (void)loadView {
	self.view = [[UITableView new] autorelease];
}

- (UITableView *)tableView {
	return (UITableView *)self.view;
}

- (CGFloat)contentHeightForOrientation:(PWWidgetOrientation)orientation {
	return 270.0;
}

- (void)willBePresentedInNavigationController:(UINavigationController *)navigationController {
	
	// add close and action buttons
	[self configureStandardButtons];
	
	// send a request to Authenticator app to retrieve records
	[self retrieveRecords];
}

- (void)triggerAction {
	// "Manage" button
	// open Google Authenticator app
	SpringBoard *app = (SpringBoard *)[UIApplication sharedApplication];
	[app launchApplicationWithIdentifier:AuthenticatorIdentifier suspended:NO];
	[self.widget dismiss];
}

/**
 * UITableViewDelegate
 **/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 90.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	cell.backgroundColor = [PWTheme parseColorString:@"#e5e5e5"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	unsigned int row = [indexPath row];
	
	// copy the code to clipboard
	[self copyCodeFromRecordAtIndex:row];
	
	// show copied text
	PWWidgetGoogleAuthenticatorTableViewCell *cell = (PWWidgetGoogleAuthenticatorTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
	[cell showCopied];
	
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
	return [_records count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	unsigned int row = [indexPath row];
	NSDictionary *record = _records[row];
	
	NSString *identifier = @"PWWidgetGoogleAuthenticatorTableViewCell";
	PWWidgetGoogleAuthenticatorTableViewCell *cell = (PWWidgetGoogleAuthenticatorTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
	
	if (!cell) {
		cell = [[[PWWidgetGoogleAuthenticatorTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
	}
	
	// type
	RecordType type = (RecordType)[record[@"type"] unsignedIntegerValue];
	[cell setReloadBtnHidden:(type != CounterBased)];
	[cell setReloadBtnTarget:self action:@selector(reloadButtonPressed:)];
	[cell setReloadBtnRecordIndex:row];
	
	// account name and issuer
	NSString *name = record[@"name"];
	NSString *issuer = record[@"issuer"];
	[cell setName:name issuer:issuer];
	
	// verification code
	NSString *code = record[@"code"];
	[cell setCode:code];
	
	// warning
	BOOL warning = [_warningRows containsObject:@(row)];
	[cell setWarning:warning];
	
	return cell;
}

- (void)timerTick {
	
	BOOL requiresUpdate = [self checkRecords:NO];
	
	if (requiresUpdate) {
		[self retrieveRecords];
	}
}

- (void)invalidateTimer {
	[_timer invalidate];
	RELEASE(_timer);
}

- (void)reloadButtonPressed:(UIButton *)sender {
	
	NSUInteger index = sender.tag;
	if ([_records count] <= index) return;
	
	// send a request to Authenticator app to retrieve verification codes
	NSDictionary *dict = @{ @"action": @"refresh", @"index": @(index) };
	[OBJCIPC sendMessageToAppWithIdentifier:AuthenticatorIdentifier messageName:@"GoogleAuthenticator" dictionary:dict replyHandler:^(NSDictionary *reply) {
		BOOL success = [reply[@"success"] boolValue];
		if (success) {
			[self retrieveRecords];
		}
	}];
}

- (BOOL)checkRecords:(BOOL)newRecords {
	
	[_warningRows release];
	_warningRows = [NSMutableSet new];
	
	BOOL requiresUpdate = NO;
	NSInteger now = ceil([[NSDate date] timeIntervalSince1970]);
	NSUInteger i = 0;
	
	for (NSDictionary *record in _records) {
		
		NSInteger warningPeriod = 2;
		NSInteger period = ceil([(NSNumber *)record[@"period"] doubleValue]);
		NSInteger time = now % period;
		
		// there is no way that period can be zero
		if (period == 0) continue;
		
		if (!newRecords && time == 1) { // hit the next interval
			
			// update records
			requiresUpdate = YES;
			[self showWarningAtRow:i];
			
		} else if (period > warningPeriod && time >= (period - warningPeriod)) {
			
			// set text color
			[self showWarningAtRow:i];
		}
		
		i++;
	}
	
	return requiresUpdate;
}

- (void)retrieveRecords {
	
	// send a request to Authenticator app to retrieve verification codes
	NSDictionary *dict = @{ @"action": @"retrieve", @"firstTime": @(_firstTime) };
	[OBJCIPC sendMessageToAppWithIdentifier:AuthenticatorIdentifier messageName:@"GoogleAuthenticator" dictionary:dict replyHandler:^(NSDictionary *reply) {
		
		_firstTime = NO;
		
		BOOL dataAvailable = [reply[@"dataAvailable"] boolValue];
		NSArray *records = reply[@"records"];
		
		if (!dataAvailable || records == nil) {
			[self.widget showMessage:@"Unable to retrieve verification codes from Google Authenticator app." title:nil handler:^{
				[self.widget dismiss];
			}];
		} else {
			
			[_records release];
			_records = [records copy];
			
			[self.tableView reloadData];
			
			// update warning
			[self checkRecords:YES];
			
			// from http://stackoverflow.com/questions/7547934/animated-reloaddata-on-uitableview
			CATransition *animation = [CATransition animation];
			[animation setType:kCATransitionFade];
			[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
			[animation setFillMode:kCAFillModeBoth];
			[animation setDuration:.2];
			[[self.tableView layer] addAnimation:animation forKey:@"fade"];
		}
	}];
}

- (void)copyCodeFromRecordAtIndex:(NSUInteger)index {
	
	// retrieve the code string
	NSString *code = nil;
	if (index < [_records count]) {
		NSDictionary *record = _records[index];
		code = record[@"code"];
	}
	
	if (code == nil) {
		[self.widget showMessage:@"Unable to copy the code."];
		return;
	}
	
	// copy the code
	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	pasteboard.string = code;
}

- (void)showWarningAtRow:(NSUInteger)row {
	[_warningRows addObject:@(row)];
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
	[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)dealloc {
	DEALLOCLOG;
	[_timer invalidate];
	RELEASE(_timer)
	RELEASE(_warningRows)
	RELEASE(_records)
	[super dealloc];
}

@end