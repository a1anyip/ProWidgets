@class MFMailAccountProxyGenerator, MFMailAccountProxy;
@class MFMessageWriter, MFOutgoingMessage, MFMutableMessageHeaders, MailAccount, DeliveryAccount, MFSecureMIMECompositionManager, MFMailDelivery;

@interface MFMailAccountProxyGenerator : NSObject

- (NSArray *)allAccountProxies;
- (MFMailAccountProxy *)defaultMailAccountProxyForDeliveryOriginatingBundleID:(id)arg1 sourceAccountManagement:(int)arg2;
- (MFMailAccountProxy *)accountProxyContainingEmailAddress:(NSString *)arg1 includingInactive:(BOOL)arg2;

@end

@interface MFMailAccountProxy : NSObject

@property(readonly) NSArray *emailAddresses;
@property(readonly) NSString *firstEmailAddress;
@property(readonly) NSString *fullUserName;

@end

@interface MFMessageWriter : NSObject

- (MFOutgoingMessage *)createMessageWithHtmlString:(NSString *)arg1 plainTextAlternative:(NSAttributedString *)arg2 otherHtmlStringsAndAttachments:(id)arg3 charsets:(NSString *)arg4 headers:(id)arg5;

@end

@interface MFOutgoingMessage : NSObject

- (MFMutableMessageHeaders *)mutableHeaders;

@end

@interface MFMutableMessageHeaders : NSObject

- (void)setHeader:(id)header forKey:(NSString *)key;
- (void)setAddressListForSender:(NSArray *)sender;
- (void)setAddressListForTo:(NSArray *)to;
- (void)setAddressListForCc:(NSArray *)cc;
- (void)setAddressListForBcc:(NSArray *)ccc;

@end

@interface MailAccount : NSObject

+ (MailAccount *)accountContainingEmailAddress:(NSString *)address;
- (DeliveryAccount *)deliveryAccount;

@end

@interface DeliveryAccount : NSObject

@end

@interface MFSecureMIMECompositionManager : NSObject

- (NSDictionary *)compositionSpecification;

@end

@interface MFMailDelivery

+ (MFMailDelivery *)newWithMessage:(MFOutgoingMessage *)message;
- (void)setCompositionSpecification:(NSDictionary *)specification;
- (void)setAccount:(DeliveryAccount *)account;
- (void)setArchiveAccount:(MailAccount *)account;
- (void)deliverAsynchronously;

@end