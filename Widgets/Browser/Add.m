//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "Add.h"
#import "Browser.h"
#import "PWContentViewController.h"
#import "PWThemableTableView.h"

@implementation PWWidgetBrowserAddBookmarkViewController

- (void)load {
	
	self.actionButtonText = @"Add";
		
	self.shouldAutoConfigureStandardButtons = NO;
	self.shouldMaximizeContentHeight = YES;
	
	//self.tableView.delegate = self;
	//self.tableView.dataSource = self;
}

- (NSString *)title {
	return @"Add Bookmark";
}

- (void)loadView {
	self.view = [[[PWThemableTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
}

- (UITableView *)tableView {
	return (UITableView *)self.view;
}

- (void)willBePresentedInNavigationController:(UINavigationController *)navigationController {
	[self configureActionButton];
}

- (void)dealloc {
	RELEASE(_bookmarkTitle)
	RELEASE(_bookmarkURL)
	[super dealloc];
}

@end