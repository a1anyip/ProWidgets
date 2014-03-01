//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"

@interface PWWidgetCalendarOverviewViewController : PWContentViewController<UITableViewDelegate, UITableViewDataSource> {
	
	UILabel *_noLabel;
	NSArray *_events;
}

- (UITableView *)tableView;
- (EKEventStore *)store;

- (void)reload;
- (void)loadEvents;

@end