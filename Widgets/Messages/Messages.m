//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "interface.h"
#import "PWWidget.h"
#import "PWWidgetItem.h"
#import "WidgetItems/items.h"
#import "API/Message.h"

@interface PWWidgetMessages : PWWidget

@end

@implementation PWWidgetMessages

- (void)submitEventHandler:(NSDictionary *)values {
	
	// items
	PWWidgetItemTextArea *contentItem = (PWWidgetItemTextArea *)[self.defaultItemViewController itemWithKey:@"content"];
	PWWidgetItemRecipient *recipientItem = (PWWidgetItemRecipient *)[self.defaultItemViewController itemWithKey:@"recipients"];
	
	// recipients
	NSArray *recipientAddresses = [recipientItem addresses];
	if ([recipientAddresses count] == 0) {
		[self showMessage:@"You must specify at least one recipient."];
		[contentItem becomeFirstResponder];
		return;
	}
	
	// content
	NSString *content = values[@"content"];
	if ([content length] == 0) {
		[self showMessage:@"Content cannot be empty."];
		[contentItem becomeFirstResponder];
		return;
	}
	
	// invoke API
	[PWAPIMessage sendMessage:content recipients:recipientAddresses];
	
	// dismiss the widget
	[self dismiss];
}

@end