//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import <EventKit/EventKit.h>
#import "interface.h"
#import "PWWidget.h"
#import "PWWidgetItem.h"
#import "WidgetItems/items.h"
#import "API/Mail.h"

@interface PWWidgetMail : PWWidget

@end

@implementation PWWidgetMail

#define REPLACE(a,b,c) a = [a stringByReplacingOccurrencesOfString:b withString:c];

- (void)submitEventHandler:(NSDictionary *)values {
	
	if (![PWAPIMail canSendMail]) {
		[self showMessage:@"Mail cannot be sent."];
		return;
	}
	
	// items
	PWWidgetItemTextArea *contentItem = (PWWidgetItemTextArea *)[self.defaultItemViewController itemWithKey:@"content"];
	PWWidgetItemRecipient *toItem = (PWWidgetItemRecipient *)[self.defaultItemViewController itemWithKey:@"to"];
	
	// to
	NSArray *toAddresses = [toItem addresses];
	if ([toAddresses count] == 0) {
		[self showMessage:@"You must specify at least one recipient."];
		[contentItem becomeFirstResponder];
		return;
	}
	
	// sender
	NSString *sender = [PWAPIMail defaultSenderAccount][@"address"];
	
	// subject
	NSString *subject = values[@"subject"];
	
	// content
	NSString *content = values[@"content"];
	
	REPLACE(content, @"<", @"&lt;")
	REPLACE(content, @">", @"&gt;")
	REPLACE(content, @" ", @"&nbsp;")
	REPLACE(content, @"\n", @"<br/>")
	
	// invoke API
	[PWAPIMail sendMailWithHTMLContent:content subject:subject sender:sender to:toAddresses];
	
	// dismiss the widget
	[self dismiss];
}

#undef REPLACE

@end