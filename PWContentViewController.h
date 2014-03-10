//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"
#import "PWContentViewControllerDelegate.h"

@interface PWContentViewController : UIViewController<PWContentViewControllerDelegate> {
	
	PWWidget *_widget;
	
	BOOL _shouldAutoConfigureStandardButtons;
	BOOL _shouldMaximizeContentHeight;
	BOOL _requiresKeyboard;
	
	UIBarButtonItem *_closeButtonItem;
	UIBarButtonItem *_actionButtonItem;
	
	NSString *_closeButtonText;
	NSString *_actionButtonText;
	
	NSMutableDictionary *_eventHandlers;
}

@property(nonatomic) BOOL shouldAutoConfigureStandardButtons;

// these two variables determine the content size and position
@property(nonatomic) BOOL wantsFullscreen;
@property(nonatomic) BOOL shouldMaximizeContentHeight;
@property(nonatomic) BOOL requiresKeyboard;

@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *closeButtonText;
@property(nonatomic, copy) NSString *actionButtonText;

+ (NSString *)actionEventName;
+ (NSString *)titleTappedEventName;

// for subclass
- (instancetype)initForWidget:(PWWidget *)widget;
- (instancetype)_initForWidget:(PWWidget *)widget; // for subclass
- (void)_setWidget:(PWWidget *)widget;

- (PWWidget *)widget;
- (PWTheme *)theme;

- (void)load;
- (BOOL)loadPlist:(NSString *)filename;

- (BOOL)isTopViewController;

// subclasses may override these methods
- (void)keyboardWillShow:(CGFloat)height;
- (void)keyboardWillHide;
- (void)configureFirstResponder;

- (void)configureCloseButton;
- (void)configureActionButton;
- (void)configureBackButton;
- (void)configureStandardButtons;
- (void)triggerClose;
- (void)triggerAction;

- (void)triggerEvent:(NSString *)event withObject:(id)object;
- (void)setHandlerForEvent:(NSString *)event target:(id)target selector:(SEL)selector;
- (void)setHandlerForEvent:(NSString *)event block:(void(^)(id))block;

- (void)setActionEventHandler:(id)target selector:(SEL)selector;
- (void)setActionEventBlockHandler:(void(^)(id))block;

- (CGFloat)contentWidthForOrientation:(PWWidgetOrientation)orientation;
- (CGFloat)contentHeightForOrientation:(PWWidgetOrientation)orientation;

// this will be called internally
- (void)_willBePresentedInNavigationController:(UINavigationController *)navigationController;
- (void)_presentedInNavigationController:(UINavigationController *)navigationController;
- (void)_dealloc;

@end