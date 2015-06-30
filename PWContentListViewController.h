//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"
#import "PWContentViewController.h"
#import "PWContentListViewControllerDelegate.h"

@interface PWContentListViewController : PWContentViewController<UITableViewDelegate, UITableViewDataSource> {
	
	id<PWContentListViewControllerDelegate> _delegate;
}

@property(nonatomic, readonly) UITableView *tableView;

- (instancetype)initWithTitle:(NSString *)title delegate:(id<PWContentListViewControllerDelegate>)delegate forWidget:(PWWidget *)widget;

- (void)reload;

@end