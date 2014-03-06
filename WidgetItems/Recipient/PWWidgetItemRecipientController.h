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

@protocol PWWidgetItemRecipientControllerDelegate <NSObject>

@required
- (void)recipientsChanged:(NSArray *)recipients;

@end

@interface PWWidgetItemRecipientController : PWContentViewController<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource> {
	
	id<PWWidgetItemRecipientControllerDelegate> _delegate;
	
	NSMutableArray *_recipients;
	NSArray *_searchResults;
}

@property(nonatomic, assign) id<PWWidgetItemRecipientControllerDelegate> delegate;

+ (NSString *)displayTextForRecipients:(NSArray *)recipients maxWidth:(CGFloat)maxWidth font:(UIFont *)font;

- (instancetype)initWithTitle:(NSString *)title delegate:(id<PWWidgetItemRecipientControllerDelegate>)delegate recipients:(NSArray *)recipients forWidget:(PWWidget *)widget;

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