//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"
#import "interface.h"
#import <objcipc/objcipc.h>

static inline __attribute__((constructor)) void init() {
	@autoreleasepool {
		
		[OBJCIPC registerIncomingMessageFromSpringBoardHandlerForMessageName:@"PWAPIMail" handler:^NSDictionary *(NSDictionary *dict) {
			
			NSString *action = dict[@"action"];
			
			LOG(@"PWAPIMail: Received action (%@)", action);
			
			if ([action isEqualToString:@"sendMail"]) {
				
				NSString *subject = dict[@"subject"];
				NSString *content = dict[@"content"];
				NSString *sender = dict[@"sender"];
				NSArray *to = dict[@"to"];
				NSArray *cc = dict[@"cc"];
				NSArray *bcc = dict[@"bcc"];
				
				LOG(@"After retrieving values");
				
				MFMessageWriter *writer = [objc_getClass("MFMessageWriter") new];
				MFOutgoingMessage *message = [writer createMessageWithHtmlString:content plainTextAlternative:nil otherHtmlStringsAndAttachments:nil charsets:nil headers:nil]; // default charset is utf-8
				
				LOG(@"After constructing message <%@>", message);
				
				// configure headers
				MFMutableMessageHeaders *headers = message.mutableHeaders;
				[headers setAddressListForSender:@[sender]];
				[headers setAddressListForTo:to];
				
				if ([cc count] > 0)
					[headers setAddressListForCc:cc];
				
				if ([bcc count] > 0)
					[headers setAddressListForBcc:bcc];
				
				// set subject
				if ([subject length] > 0) {
					NSData *subjectData = [subject dataUsingEncoding:NSUTF8StringEncoding];
					[headers setHeader:subjectData forKey:@"subject"];
				}
				
				LOG(@"After configuring headers");
				
				// mail account
				MailAccount *mailAccount = [objc_getClass("MailAccount") accountContainingEmailAddress:sender];
				DeliveryAccount *deliveryAccount = mailAccount.deliveryAccount;
				
				LOG(@"After retrieving mail account");
				
				// composition manager
				MFSecureMIMECompositionManager *compositionManager = [objc_getClass("MFSecureMIMECompositionManager") new];
				NSDictionary *compositionSpecification = [compositionManager compositionSpecification];
				[compositionManager release];
				
				// delivery object
				MFMailDelivery *delivery = [objc_getClass("MFMailDelivery") newWithMessage:message];
				[delivery setCompositionSpecification:compositionSpecification];
				[delivery setAccount:deliveryAccount];
				[delivery setArchiveAccount:mailAccount];
				
				LOG(@"After configuring delivery object");
				
				// send asynchronously
				[delivery deliverAsynchronously];
				
				LOG(@"After delivery");
			}
			
			return nil;
		}];
		
	}
}