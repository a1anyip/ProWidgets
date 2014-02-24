//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWThemableTableView.h"
#import "PWController.h"
#import "PWTheme.h"

static char PWThemableTableViewHeaderFooterViewConfiguredKey;

@interface UITableView (Private)

- (UITableViewHeaderFooterView *)_sectionHeaderView:(BOOL)arg1 withFrame:(CGRect)frame forSection:(int)section floating:(BOOL)floating reuseViewIfPossible:(BOOL)reuse;

@end

@implementation PWThemableTableView

- (instancetype)init {
	if ((self = [super init])) {
		[self _configureAppearance];
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
	if ((self = [super initWithFrame:frame style:style])) {
		[self _configureAppearance];
	}
	return self;
}

- (void)_configureAppearance {
	
	// set background color
	self.backgroundColor = [UIColor clearColor];
	
	// set table view
	self.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.alwaysBounceVertical = NO;
	
	// hide separator in empty cells
	[self setHideSeparatorInEmptyCells:YES];
}

- (UITableViewHeaderFooterView *)_sectionHeaderView:(BOOL)arg1 withFrame:(CGRect)frame forSection:(int)section floating:(BOOL)floating reuseViewIfPossible:(BOOL)reuse {
	
	UITableViewHeaderFooterView *view = [super _sectionHeaderView:arg1 withFrame:frame forSection:section floating:floating reuseViewIfPossible:reuse];
	
	NSNumber *configured = objc_getAssociatedObject(view, &PWThemableTableViewHeaderFooterViewConfiguredKey);
	if (configured == nil || ![configured boolValue]) {
		
		[view setOpaque:NO];
		
		// configure its appearance
		PWTheme *theme = [PWController activeTheme];
		view.contentView.backgroundColor = [theme cellHeaderFooterViewBackgroundColor];
		view.textLabel.textColor = [theme cellHeaderFooterViewTitleTextColor];
		view.detailTextLabel.textColor = [theme cellHeaderFooterViewTitleTextColor];
		
		objc_setAssociatedObject(view, &PWThemableTableViewHeaderFooterViewConfiguredKey, @(YES), OBJC_ASSOCIATION_COPY);
	}
	
	return view;
}

- (void)setHideSeparatorInEmptyCells:(BOOL)hidden {
	if (hidden) {
		// remove separator lines for empty cells
		UIView *emptyView = [[UIView alloc] initWithFrame:CGRectZero];
		emptyView.backgroundColor = [UIColor clearColor];
		[self setTableFooterView:emptyView];
		[emptyView release];
	} else {
		[self setTableFooterView:nil];
	}
}

@end