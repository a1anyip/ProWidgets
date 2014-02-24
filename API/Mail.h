//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "../header.h"
#import "../JSBridge/PWJSBridgeWrapper.h"
#import "MailSubstrate/interface.h"

@protocol PWAPIMailWrapperExport <JSExport>

- (void)send:(JSValue *)htmlContent :(JSValue *)subject :(JSValue *)from :(JSValue *)to :(JSValue *)cc :(JSValue *)bcc;

- (NSDictionary *)defaultSenderAccount;
- (NSArray *)availableSenderAccounts;
- (NSString *)fullNameForSenderAddress:(JSValue *)address;

@end

@interface PWAPIMailWrapper : PWJSBridgeWrapper<PWAPIMailWrapperExport>
@end

@interface PWAPIMail : NSObject

+ (void)sendMailWithHTMLContent:(NSString *)htmlContent subject:(NSString *)subject sender:(NSString *)sender to:(NSString *)to;
+ (void)sendMailWithHTMLContent:(NSString *)htmlContent subject:(NSString *)subject sender:(NSString *)sender to:(NSArray *)to cc:(NSArray *)cc bcc:(NSArray *)bcc;

+ (NSDictionary *)defaultSenderAccount;
+ (NSArray *)availableSenderAccounts;
+ (NSString *)fullNameForSenderAddress:(NSString *)address;

+ (NSDictionary *)_senderToDictionary:(MFMailAccountProxy *)accountProxy;

@end