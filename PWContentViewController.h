//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"

@interface PWContentViewController : UIViewController {
	
	PWWidget *_widget;
	
	BOOL _shouldAutoConfigureStandardButtons;
	BOOL _wantsFullscreen;
	BOOL _shouldMaximizeContentHeight;
	BOOL _requiresKeyboard;
	
	UIBarButtonItem *_closeButtonItem;
	UIBarButtonItem *_actionButtonItem;
	
	NSString *_closeButtonText;
	NSString *_actionButtonText;
	
	NSMutableDictionary *_eventHandlers;
}

/**
 *  Indicates whether this content view controller should configure the standard buttons automatically.
 */
@property(nonatomic) BOOL shouldAutoConfigureStandardButtons;

/**
 *  Indicates whether the widget should maximize the content size for this content view controller regardless of any other settings.
 */
@property(nonatomic) BOOL wantsFullscreen;

/**
 *  Indicates whether the widget should maximize the content height for this content view controller.
 */
@property(nonatomic) BOOL shouldMaximizeContentHeight;

/**
 *  Indicates whether the content of this content view controller requires a keyboard. This affects the position of the widget.
 */
@property(nonatomic) BOOL requiresKeyboard;

/**
 *  The title of this content view controller. This will be shown in the navigation bar.
 */
@property(nonatomic, copy) NSString *title;

/**
 *  The text shown in the close button.
 */
@property(nonatomic, copy) NSString *closeButtonText;

/**
 *  The text shown in the action button.
 */
@property(nonatomic, copy) NSString *actionButtonText;

/**
 *  Retrieve the event name for close event.
 *
 *  @return The event name for close event.
 */
+ (NSString *)closeEventName;

/**
 *  Retrieve the event name for aciton event.
 *
 *  @return The event name for action event.
 */
+ (NSString *)actionEventName;

/**
 *  Retrieve the event name for title tapped event.
 *
 *  @return The event name for title tapped event.
 */
+ (NSString *)titleTappedEventName;

/**
 *  The initializer of content view controller.
 *  You must not call init directly.
 *  If you are to subclass this class, [super initForWidget:] method must be called.
 *
 *  @param widget The widget that this content view controller will be pushed to.
 *
 *  @return The content view controller instance.
 */
- (instancetype)initForWidget:(PWWidget *)widget;
- (instancetype)_initForWidget:(PWWidget *)widget; // for subclass
- (void)_setWidget:(PWWidget *)widget;

/**
 *  Retrieve the widget instance associated with this content view controller.
 *
 *  @return The widget instance.
 */
- (PWWidget *)widget;

/**
 *  Retrieve the theme instance associated with the widget.
 *
 *  @return The theme instance.
 */
- (PWTheme *)theme;

/**
 *  Override this method to perform custom tasks when this class is being initialized.
 *  It is recommended to override this method rather than overriding initForWidget: directly.
 *  The default implementation does nothing.
 */
- (void)load;

/**
 *  Load the plist file for this content view controller
 *
 *  @param filename The name of the plist file.
 *
 *  @return Return YES if the plist file is loaded; otherwise, return NO.
 */
- (BOOL)loadPlist:(NSString *)filename;

/**
 *  To check whether this content view controller is at the top of the navigation stack in the associated widget.
 *
 *  @return Return YES if this content view controller is the top view controller in the navigation stack in the associated widget; otherwise, return NO.
 */
- (BOOL)isTopViewController;

/**
 *  Notifies the content view controller that the keyboard with the specified height will show.
 *
 *  @param height The height of the keyboard.
 */
- (void)keyboardWillShow:(CGFloat)height;

/**
 *  Notifies the content view controller that the keyboard will hide.
 */
- (void)keyboardWillHide;

/**
 *  Override this method to configure the first responder.
 *  The default implementation of this base class does nothing.
 */
- (void)configureFirstResponder;

/**
 *  Configure the close button in the navigation item.
 */
- (void)configureCloseButton;

/**
 *  Configure the action button in the navigation item.
 */
- (void)configureActionButton;

/**
 *  Configure the back button in the navigation item.
 */
- (void)configureBackButton;

/**
 *  Configure the standard buttons, including the close, action and back buttons, in the navigation item at once.
 */
- (void)configureStandardButtons;

/**
 *  Trigger the close event.
 *  You should register an event handler for close event instead of overriding this method.
 */
- (void)triggerClose;

/**
 *  Trigger the action event.
 *  You should register an event handler for action event instead of overriding this method.
 */
- (void)triggerAction;

/**
 *  Trigger an event with a specified name and object.
 *
 *  @param event  The event name.
 *  @param object The object to be sent to the event handler. This can be nil.
 */
- (void)triggerEvent:(NSString *)event withObject:(id)object;

/**
 *  Set the event handler for a specified event name.
 *
 *  @param event    The event name
 *  @param target   The handler receiver.
 *  @param selector The handler selector.
 */
- (void)setHandlerForEvent:(NSString *)event target:(id)target selector:(SEL)selector;

/**
 *  Set the event handler for a specified event name with a block.
 *
 *  @param event The event name.
 *  @param block The handler block.
 */
- (void)setHandlerForEvent:(NSString *)event block:(void(^)(id))block;

/**
 *  A shortcut to set the event handler for close event.
 *
 *  @param target   The handler receiver.
 *  @param selector The handler selector.
 */
- (void)setCloseEventHandler:(id)target selector:(SEL)selector;

/**
 *  A shortcut to set the event handler for close event with a block.
 *
 *  @param block The handler block.
 */
- (void)setCloseEventBlockHandler:(void(^)(id))block;

/**
 *  A shortcut to set the event handler for action event.
 *
 *  @param target   The handler receiver.
 *  @param selector The handler selector.
 */
- (void)setActionEventHandler:(id)target selector:(SEL)selector;

/**
 *  A shortcut to set the event handler for action event with a block.
 *
 *  @param block The handler block.
 */
- (void)setActionEventBlockHandler:(void(^)(id))block;

/**
 *  Override this method to return the preferred content width for this content view controller according to the specified orientation.
 *
 *  @param orientation The current orientation.
 *
 *  @return The content width for this content view controller in the specified orientation.
 */
- (CGFloat)contentWidthForOrientation:(PWWidgetOrientation)orientation;

/**
 *  Override this method to return the preferred content height for this content view controller according to the specified orientation.
 *
 *  @param orientation The current orientation.
 *
 *  @return The content height for this content view controller in the specified orientation.
 */
- (CGFloat)contentHeightForOrientation:(PWWidgetOrientation)orientation;

- (void)willBePresentedInNavigationController:(UINavigationController *)navigationController;

// this will be called internally
- (void)_willBePresentedInNavigationController:(UINavigationController *)navigationController;
- (void)_presentedInNavigationController:(UINavigationController *)navigationController;
- (void)_dealloc;

@end