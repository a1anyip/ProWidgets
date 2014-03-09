//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "../item.h"
#import "../../PWContentViewController.h"
#import "PWWidgetItemRecipientView.h"

typedef enum {
	
	PWWidgetItemRecipientTypePhoneContact,
	PWWidgetItemRecipientTypeMailContact,
	
} PWWidgetItemRecipientType;

@protocol PWWidgetItemRecipientControllerDelegate <NSObject>

@required
- (void)recipientsChanged:(NSArray *)recipients;

@end

@interface PWWidgetItemRecipientController : PWContentViewController<MFMailComposeContactsSearchControllerDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource> {
	
	id<PWWidgetItemRecipientControllerDelegate> _delegate;
	PWWidgetItemRecipientType _type;
	
	// for PWWidgetItemRecipientTypePhoneContact
	
	
	// for PWWidgetItemRecipientTypeMailContact
	MFMailComposeContactsSearchController *_mailContactSearchController;
	
	NSMutableArray *_recipients;
	NSArray *_searchResults;
}

@property(nonatomic, assign) id<PWWidgetItemRecipientControllerDelegate> delegate;
@property(nonatomic, assign) PWWidgetItemRecipientType type;

+ (NSString *)displayTextForRecipients:(NSArray *)recipients maxWidth:(CGFloat)maxWidth font:(UIFont *)font;

- (instancetype)initWithTitle:(NSString *)title delegate:(id<PWWidgetItemRecipientControllerDelegate>)delegate recipients:(NSArray *)recipients type:(PWWidgetItemRecipientType)type forWidget:(PWWidget *)widget;

- (PWWidgetItemRecipientView *)recipientView;
- (NSString *)displayTextInMaxWidth:(CGFloat)maxWidth font:(UIFont *)font;

- (void)resetState;

- (NSArray *)recipients;
- (void)setRecipients:(NSArray *)recipients;
- (void)addRecipient:(MFComposeRecipient *)recipient;
- (void)removeRecipient:(MFComposeRecipient *)recipient;

- (void)updateRecipients;
- (void)updateSearchResults:(NSArray *)results;

@end