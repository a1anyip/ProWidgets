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
	return [NSDictionary class];
}

+ (NSDictionary *)defaultValue {
	
	NSString *defaultSelectedTitle;
	NSUInteger defaultSelectedIdentifier;
	[PWBrowserWidgetItemFolderController getDefaultSelectedTitle:&defaultSelectedTitle selectedIdentifier:&defaultSelectedIdentifier];
	
	if (defaultSelectedTitle == nil) defaultSelectedTitle = @"None";
	
	return @{ @"identifier": @(defaultSelectedIdentifier), @"title": defaultSelectedTitle };
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
		_folderController.delegate = self;
	}
	
	[self.itemViewController.widget pushViewController:_folderController animated:YES];
}

- (void)selectedFolderChanged {
	
	NSString *selectedTitle = _folderController.selectedTitle;
	NSUInteger selectedIdentifier = _folderController.selectedIdentifier;
	
	if (selectedTitle == nil) selectedTitle = @"None";
	
	[self setValue:@{ @"identifier": @(selectedIdentifier), @"title": selectedTitle }];
	
	[self.itemViewController.widget popViewController];
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

- (void)setValue:(NSDictionary *)value {
	NSString *title = value[@"title"];
	self.detailTextLabel.text = title;
	[self setNeedsLayout]; // this line is important to instantly reflect the new value
}

- (BOOL)shouldShowChevron {
	return YES;
}

@end