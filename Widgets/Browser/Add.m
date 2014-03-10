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

@implementation PWWidgetBrowserAddBookmarkViewController

- (void)load {
	
	self.actionButtonText = @"Add";
		
	self.shouldAutoConfigureStandardButtons = NO;
	self.wantsFullscreen = YES;
	
	_titleItem = [[PWWidgetItemTextField createItemForItemViewController:self] retain];
	_titleItem.key = @"title";
	_titleItem.title = @"Title";
	
	_addressItem = [[PWWidgetItemTextField createItemForItemViewController:self] retain];
	_addressItem.key = @"address";
	_addressItem.title = @"Address";
	
	[self addItem:_titleItem];
	[self addItem:_addressItem];
	
	[self setSubmitEventHandler:self selector:@selector(submitEventHandler:)];
	[self setHandlerForEvent:[PWContentViewController titleTappedEventName] target:self selector:@selector(titleTapped)];
}

- (NSString *)title {
	return @"Add Bookmark";
}

- (void)willBePresentedInNavigationController:(UINavigationController *)navigationController {
	[self configureActionButton];
}

- (void)titleTapped {
	[[PWWidgetBrowser widget] switchToWebInterface];
}

- (void)updatePrefillTitle:(NSString *)title andAddress:(NSString *)address {
	[_titleItem setValue:title];
	[_addressItem setValue:address];
}

- (void)submitEventHandler:(NSDictionary *)values {
	NSString *title = values[@"title"];
	NSString *address = values[@"address"];
	[self.widget showMessage:address title:title];
}

- (void)dealloc {
	RELEASE(_titleItem)
	RELEASE(_addressItem)
	[super dealloc];
}

@end