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

@end

@interface PWWidgetItemRecipientCell : PWWidgetItemCell {
	
}

@end