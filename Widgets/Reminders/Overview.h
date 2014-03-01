//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"

@interface PWWidgetRemindersOverviewViewController : PWContentViewController<UITableViewDelegate, UITableViewDataSource> {
	
	UILabel *_noLabel;
	NSMutableArray *_reminders;
}

- (UITableView *)tableView;
- (EKEventStore *)store;

- (void)reload;
- (void)loadReminders;

@end