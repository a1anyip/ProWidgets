//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWJSBridgeWrapper.h"
#import "PWJSBridgeBaseWrapper.h"

@protocol PWJSBridgeWidgetWrapperExport <PWJSBridgeBaseWrapperExport, JSExport>

// getter
@property(nonatomic, readonly) BOOL isPresenting;
/*
@property(nonatomic, readonly) NSString *name;
@property(nonatomic, readonly) NSDictionary *userInfo;
*/
// getter and setter
@property(nonatomic, retain) JSValue *items;

// callbacks
@property(nonatomic, retain) JSValue *configure;
@property(nonatomic, retain) JSValue *load;
@property(nonatomic, retain) JSValue *willPresent;
@property(nonatomic, retain) JSValue *didPresent;
@property(nonatomic, retain) JSValue *willDismiss;
@property(nonatomic, retain) JSValue *didDismiss;
@property(nonatomic, retain) JSValue *willMinimize;
@property(nonatomic, retain) JSValue *didMinimize;
@property(nonatomic, retain) JSValue *willMaximize;
@property(nonatomic, retain) JSValue *didMaximize;
@property(nonatomic, retain) JSValue *configureFirstResponder;
@property(nonatomic, retain) JSValue *itemValueChangedEventHandler;
@property(nonatomic, retain) JSValue *closeEventHandler;
@property(nonatomic, retain) JSValue *submitEventHandler;

- (void)maximize;
- (void)minimize;
- (void)dismiss;

// Loaders
- (BOOL)loadWidgetPlist:(JSValue *)filename;
- (BOOL)loadThemePlist:(JSValue *)filename;

// Setters
- (void)setPreferredTintColor:(JSValue *)value;
- (void)setPreferredBarTextColor:(JSValue *)value;
- (void)setWantsFullscreen:(BOOL)value;
- (void)setShouldMaximizeContentHeight:(BOOL)value;
- (void)setRequiresKeyboard:(BOOL)value;
- (void)setTitle:(JSValue *)value;
- (void)setCloseButtonText:(JSValue *)value;
- (void)setActionButtonText:(JSValue *)value;

// Items

// set value
- (void)setValue:(id)value forItem:(JSValue *)item;

// retrieve item
- (PWJSBridgeWidgetItemWrapper *)itemWithKey:(JSValue *)key;
- (PWJSBridgeWidgetItemWrapper *)itemAtIndex:(JSValue *)index;
- (NSUInteger)indexOfItem:(JSValue *)item;

// addition
- (void)addItem:(JSValue *)item :(JSValue *)index :(JSValue *)animated;
- (void)addItems:(JSValue *)item :(JSValue *)index :(JSValue *)animated;
- (PWJSBridgeWidgetItemWrapper *)addItemNamed:(JSValue *)name :(JSValue *)index :(JSValue *)animated;

- (void)removeItem:(JSValue *)item :(JSValue *)animated;
- (void)removeItemAtIndex:(JSValue *)index :(JSValue *)animated;

// helper methods
//- (void)showMessage:(JSValue *)message :(JSValue *)title;
//- (void)prompt:(JSValue *)message :(JSValue *)title :(JSValue *)buttonTitle :(JSValue *)defaultValue :(JSValue *)style :(JSValue *)completion;

@end

@interface PWJSBridgeWidgetWrapper : PWJSBridgeBaseWrapper<PWJSBridgeWidgetWrapperExport> {
	
	// callbacks
	JSManagedValue *_configure;
	JSManagedValue *_load;
	JSManagedValue *_willPresent;
	JSManagedValue *_didPresent;
	JSManagedValue *_willDismiss;
	JSManagedValue *_didDismiss;
	JSManagedValue *_willMinimize;
	JSManagedValue *_didMinimize;
	JSManagedValue *_willMaximize;
	JSManagedValue *_didMaximize;
	JSManagedValue *_configureFirstResponder;
	JSManagedValue *_itemValueChangedEventHandler;
	JSManagedValue *_submitEventHandler;
	JSManagedValue *_closeEventHandler;
}

@property(nonatomic, readonly) PWWidget *widget;
@property(nonatomic, readonly) PWContentItemViewController *itemViewController;

// callbacks
@property(nonatomic, retain) JSValue *configure;
@property(nonatomic, retain) JSValue *load;
@property(nonatomic, retain) JSValue *willPresent;
@property(nonatomic, retain) JSValue *didPresent;
@property(nonatomic, retain) JSValue *willDismiss;
@property(nonatomic, retain) JSValue *didDismiss;
@property(nonatomic, retain) JSValue *willMinimize;
@property(nonatomic, retain) JSValue *didMinimize;
@property(nonatomic, retain) JSValue *willMaximize;
@property(nonatomic, retain) JSValue *didMaximize;
@property(nonatomic, retain) JSValue *configureFirstResponder;
@property(nonatomic, retain) JSValue *itemValueChangedEventHandler;
@property(nonatomic, retain) JSValue *submitEventHandler;
@property(nonatomic, retain) JSValue *closeEventHandler;

@end