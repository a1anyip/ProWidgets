//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "Mail.h"
#import "../PWController.h"
#import "../JSBridge/PWJSBridgeWrapper.h"
#import <objcipc/objcipc.h>

#define MailIdentifier @"com.apple.mobilemail"

@implementation PWAPIMailWrapper

- (BOOL)canSendMail {
	return [PWAPIMail canSendMail];
}

- (void)send:(JSValue *)htmlContent :(JSValue *)subject :(JSValue *)sender :(JSValue *)to :(JSValue *)cc :(JSValue *)bcc {
	
	if ([sender isUndefined] || [to isUndefined]) {
		[_bridge throwException:@"send: requires at least 2 arguments (sender address and 'to' recipient array)"];
		return;
	}
	
	NSString *_htmlContent = [htmlContent isUndefined] ? nil : [htmlContent toString];
	NSString *_subject = [subject isUndefined] ? nil : [subject toString];
	NSString *_sender = [sender isNull] ? nil : [sender toString];
	
	if (_sender == nil || [_sender length] == 0) {
		[_bridge throwException:@"send: sender address cannot be empty"];
		return;
	}
	
	NSArray *_to = nil;
	NSArray *_cc = nil;
	NSArray *_bcc = nil;
	
#define ACCEPT_STRING(recipients) if (![recipients isObject]) {\
		_##recipients = [recipients isString] ? @[[recipients toString]] : @[];\
	} else {\
		_##recipients = [recipients toArray];\
	}
	
	ACCEPT_STRING(to)
	ACCEPT_STRING(cc)
	ACCEPT_STRING(bcc)
	
#undef ACCEPT_STRING
	
	if ([_to count] == 0) {
		[_bridge throwException:@"send: 'to' recipient cannot be empty"];
		return;
	}
	
	[PWAPIMail sendMailWithHTMLContent:_htmlContent subject:_subject sender:_sender to:_to cc:_cc bcc:_bcc];
}

- (NSDictionary *)defaultSenderAccount {
	return [PWAPIMail defaultSenderAccount];
}

- (NSArray *)availableSenderAccounts {
	return [PWAPIMail availableSenderAccounts];
}

- (NSString *)fullNameForSenderAddress:(JSValue *)address {
	return [PWAPIMail fullNameForSenderAddress:[address toString]];
}

@end

@interface MSAccounts : NSObject

+ (BOOL)canSendMail;

@end

@implementation PWAPIMail

+ (BOOL)canSendMail {
	return [MSAccounts canSendMail];
}

+ (void)sendMailWithHTMLContent:(NSString *)htmlContent subject:(NSString *)subject sender:(NSString *)sender to:(NSArray *)to {
	[self sendMailWithHTMLContent:htmlContent subject:subject sender:sender to:to cc:nil bcc:nil];
}

+ (void)sendMailWithHTMLContent:(NSString *)htmlContent subject:(NSString *)subject sender:(NSString *)sender to:(NSArray *)to cc:(NSArray *)cc bcc:(NSArray *)bcc {
	
	CHECK_API();
	
	if (htmlContent == nil)
		htmlContent = @"";
	
	// ensure the HTML content is string
	if (![htmlContent isKindOfClass:[NSString class]]) {
		LOG(@"PWAPIMail: HTML content must be string");
		return;
	}
	
	if (subject == nil)
		subject = @"";
	
	// ensure the subject is string
	if (![subject isKindOfClass:[NSString class]]) {
		LOG(@"PWAPIMail: Subject must be string");
		return;
	}
	
	if (sender == nil || ![sender isKindOfClass:[NSString class]] || [sender length] == 0) {
		LOG(@"PWAPIMail: Sender must be string and not empty");
		return;
	}
	
	// ensure there is at least one 'to' recipient
	if ([to count] == 0) {
		LOG(@"PWAPIMail: There must be at least one 'to' recipient");
		return;
	}
	
	// ensure every element in recipients is string
	BOOL(^validateRecipients)(NSArray *) = ^BOOL(NSArray *recipients) {
		
		if (recipients == nil || [recipients count] == 0) return YES;
		
		for (NSString *recipient in recipients) {
			if (![recipient isKindOfClass:[NSString class]]) {
				LOG(@"PWAPIMail: All recipient must be NSString");
				return NO;
			} else if ([recipient length] == 0) {
				LOG(@"PWAPIMail: Recipient cannot be empty");
				return NO;
			}
		}
		
		return YES;
	};
	
#define VALIDATE(recipients) if (recipients == nil) recipients = @[];\
else if (!validateRecipients(recipients)) return;
	
	VALIDATE(to)
	VALIDATE(cc)
	VALIDATE(bcc)
	
#undef VALIDATE
	
	// construct the dictionary
	NSDictionary *dict = @{
						   @"action": @"sendMail",
						   @"subject": subject,
						   @"content": htmlContent,
						   @"sender": sender,
						   @"to": to,
						   @"cc": cc,
						   @"bcc": bcc
						   };
	
	[OBJCIPC sendMessageToAppWithIdentifier:MailIdentifier messageName:@"PWAPIMail" dictionary:dict replyHandler:nil];
}

+ (NSDictionary *)defaultSenderAccount {
	
	CHECK_API(nil);
	
	MFMailAccountProxyGenerator *generator = [objc_getClass("MFMailAccountProxyGenerator") new];
	MFMailAccountProxy *accountProxy = [generator defaultMailAccountProxyForDeliveryOriginatingBundleID:nil sourceAccountManagement:0];
	
	return [self _senderToDictionary:accountProxy];
}

+ (NSArray *)availableSenderAccounts {
	
	CHECK_API(nil);
	
	NSMutableArray *accounts = [NSMutableArray array];
	MFMailAccountProxyGenerator *generator = [objc_getClass("MFMailAccountProxyGenerator") new];
	NSArray *accountProxies = [generator allAccountProxies];
	
	for (MFMailAccountProxy *proxy in accountProxies) {
		NSDictionary *account = [self _senderToDictionary:proxy];
		[accounts addObject:account];
	}
	
	[generator release];
	
	return [[accounts copy] autorelease];
}

+ (NSString *)fullNameForSenderAddress:(NSString *)address {
	
	CHECK_API(nil);
	
	MFMailAccountProxyGenerator *generator = [objc_getClass("MFMailAccountProxyGenerator") new];
	MFMailAccountProxy *accountProxy = [generator accountProxyContainingEmailAddress:address includingInactive:NO];
	[generator release];
	
	if (accountProxy != nil) {
		return accountProxy.fullUserName;
	} else {
		return nil;
	}
}

+ (NSDictionary *)_senderToDictionary:(MFMailAccountProxy *)accountProxy {
	return @{
			 @"fullName": accountProxy.fullUserName,
			 @"address": accountProxy.firstEmailAddress
			 };
}

@end