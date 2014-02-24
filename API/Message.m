//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "Message.h"
#import "../JSBridge/PWJSBridgeWrapper.h"
#import <objcipc/objcipc.h>

#define MessagesIdentifier @"com.apple.MobileSMS"

@implementation PWAPIMessageWrapper

- (void)send:(JSValue *)content :(JSValue *)recipients {
	
	if ([content isUndefined] || [recipients isUndefined]) {
		[_bridge throwException:@"send: requires 2 arguments (content and recipient array)"];
		return;
	}
	
	NSString *_content = [content isNull] ? nil : [content toString];
	NSArray *_recipients = nil;
	
	if (![recipients isObject]) {
		_recipients = [recipients isString] ? @[[recipients toString]] : @[];
	} else {
		_recipients = [recipients toArray];
	}
	
	[PWAPIMessage sendMessage:_content recipients:_recipients];
}

@end

@implementation PWAPIMessage

+ (void)sendMessage:(NSString *)content recipients:(NSArray *)recipients {
	
	if (content == nil)
		content = @"";
	
	// ensure the content is string
	if (content != nil && ![content isKindOfClass:[NSString class]]) {
		LOG(@"PWAPIMessage: Message content must be string");
		return;
	}
	
	// ensure there is at least one recipient
	if ([recipients count] == 0) {
		LOG(@"PWAPIMessage: There must be at least one recipient");
		return;
	}
	
	// ensure every element in recipients is string
	for (NSObject *recipient in recipients) {
		if (![recipient isKindOfClass:[NSString class]]) {
			LOG(@"PWAPIMessage: All recipient objects must be NSString");
			return;
		}
	}
	
	// construct the dictionary
	NSDictionary *dict = @{
						   @"action": @"sendMessage",
						   @"recipients": recipients,
						   @"content": content
						   };
	
	[OBJCIPC sendMessageToAppWithIdentifier:MessagesIdentifier messageName:@"PWAPIMessage" dictionary:dict replyHandler:nil];
}

@end