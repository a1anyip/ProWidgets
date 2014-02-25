//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "item.h"
#import "Recipient/PWWidgetItemRecipientController.h"

@interface PWWidgetItemRecipient : PWWidgetItem<PWWidgetItemRecipientControllerDelegate> {
	
	PWWidgetItemRecipientController *_recipientController;
	NSString *_titleWithoutColon;
}

- (NSArray *)addresses;
- (void)setAddresses:(NSArray *)addresses;
- (void)addAddress:(NSString *)address;
- (void)removeAddress:(NSString *)address;

- (NSArray *)recipients;
- (void)setRecipients:(NSArray *)recipients;
- (void)addRecipient:(MFComposeRecipient *)recipient;
- (void)removeRecipient:(MFComposeRecipient *)recipient;

@end

@interface PWWidgetItemRecipientCell : PWWidgetItemCell {
	
}

@end