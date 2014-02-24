@class CKConversationList, CKConversation, CKComposition, CKIMMessage, CKEntity;

@interface CKConversationList : NSObject

+ (instancetype)sharedConversationList;
- (CKConversation *)conversationForRecipients:(NSArray *)recipients create:(BOOL)create;

@end

@interface CKConversation : NSObject

- (CKIMMessage *)newMessageWithComposition:(CKComposition *)composition;
- (void)sendMessage:(CKIMMessage *)message newComposition:(BOOL)newComposition;

@end

@interface CKComposition : NSObject

- (id)initWithText:(NSAttributedString *)text subject:(NSString *)subject;

@end

@interface CKIMMessage : NSObject
@end

@interface CKEntity : NSObject

+ (CKEntity *)copyEntityForAddressString:(NSString *)address;

@end