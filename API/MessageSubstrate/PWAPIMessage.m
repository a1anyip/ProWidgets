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
		
		[OBJCIPC registerIncomingMessageFromSpringBoardHandlerForMessageName:@"PWAPIMessage" handler:^NSDictionary *(NSDictionary *dict) {
			
			NSString *action = dict[@"action"];
			
			LOG(@"PWAPIMessage: Received action (%@)", action);
			
			if ([action isEqualToString:@"sendMessage"]) {
				
				NSString *content = dict[@"content"];
				NSArray *recipientAddresses = dict[@"recipients"];
				NSMutableArray *recipients = [NSMutableArray array];
				
				// convert recipient addresses into entities
				for (NSString *address in recipientAddresses) {
					CKEntity *entity = [objc_getClass("CKEntity") copyEntityForAddressString:address];
					if (entity != nil)
						[recipients addObject:entity];
				}
				
				LOG(@"PWAPIMessage: Send message <recipients: %@> <content: %@>", recipients, content);
				
				if ([recipients count] == 0) return nil;
				
				// retrieve the conversation
				CKConversationList *conversationList = [objc_getClass("CKConversationList") sharedConversationList];
				CKConversation *conversation = [conversationList conversationForRecipients:recipients create:YES];
				
				// construct composition
				NSAttributedString *text = [[NSAttributedString alloc] initWithString:content];
				CKComposition *composition = [[objc_getClass("CKComposition") alloc] initWithText:text subject:nil];
				[text release];
				
				// construct message
				CKIMMessage *message = [conversation newMessageWithComposition:composition];
				[composition release];
				
				// send the message
				[conversation sendMessage:message newComposition:YES];
			}
			
			return nil;
		}];
		
	}
}