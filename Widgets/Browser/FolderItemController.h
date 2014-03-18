//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "../../WidgetItems/item.h"
#import "../../PWContentViewController.h"

@interface PWBrowserWidgetItemFolderController : PWContentViewController<UITableViewDelegate, UITableViewDataSource> {
	
	id _delegate;
	
	NSString *_selectedTitle;
	NSUInteger _selectedIdentifier;
	NSArray *_folders;
}

@property(nonatomic, assign) id delegate;
@property(nonatomic, readonly) NSString *selectedTitle;
@property(nonatomic, readonly) NSUInteger selectedIdentifier;

+ (void)getDefaultSelectedTitle:(NSString **)selectedTitleOut selectedIdentifier:(NSUInteger *)selectedIdentifierOut;

- (UITableView *)tableView;

@end