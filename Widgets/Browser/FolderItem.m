//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "FolderItem.h"

@implementation PWBrowserWidgetItemFolder

+ (Class)valueClass {
	return [NSNumber class];
}

+ (id)defaultValue {
	return nil;
}

+ (Class)cellClass {
	return [PWBrowserWidgetItemFolderCell class];
}

- (BOOL)isSelectable {
	return YES;
}

- (void)select {
	
	if (_folderController == nil) {
		_folderController = [[PWBrowserWidgetItemFolderController alloc] initForWidget:self.itemViewController.widget];
	}
	
	[self.itemViewController.widget pushViewController:_folderController animated:YES];
}

- (void)dealloc {
	RELEASE(_folderController)
	[super dealloc];
}

@end

@implementation PWBrowserWidgetItemFolderCell

//////////////////////////////////////////////////////////////////////

+ (PWWidgetItemCellStyle)cellStyle {
	return PWWidgetItemCellStyleValue;
}

//////////////////////////////////////////////////////////////////////

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier theme:(PWTheme *)theme {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier theme:theme])) {
		
	}
	return self;
}

- (void)setTitle:(NSString *)title {
	self.textLabel.text = title;
}

- (void)setValue:(NSArray *)value {
	self.detailTextLabel.text = @"Bookmark";
	[self setNeedsLayout]; // this line is important to instantly reflect the new value
}

- (BOOL)shouldShowChevron {
	return YES;
}

@end