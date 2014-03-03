//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"

@interface PWWidgetBrowserBookmarkViewController : PWContentViewController<UITableViewDelegate, UITableViewDataSource> {
	
	BOOL _isRoot;
	NSUInteger _folderIdentifier;
	NSString *_folderTitle;
	NSMutableArray *_items;
}

@property(nonatomic, assign) BOOL isRoot;
@property(nonatomic, assign) NSUInteger folderIdentifier;
@property(nonatomic, copy) NSString *folderTitle;

- (UITableView *)tableView;
- (void)reload;

- (void)loadBookmarkItems;

@end