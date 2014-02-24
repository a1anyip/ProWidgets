//
//  ProWidgets
//  Google Authenticator
//
//  Created by Alan Yip on 22 Feb 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"
#import "interface.h"
#import "PWContentViewController.h"

@interface PWWidgetGoogleAuthenticatorViewController : PWContentViewController<UITableViewDelegate, UITableViewDataSource> {
	
	NSTimer *_timer;
	NSMutableSet *_warningRows;
	NSArray *_records;
}

- (UITableView *)tableView;

- (void)timerTick;
- (void)invalidateTimer;
- (BOOL)checkRecords:(BOOL)newRecords;
- (void)retrieveRecords;
- (void)copyCodeFromRecordAtIndex:(NSUInteger)index;
- (void)showWarningAtRow:(NSUInteger)row;

@end