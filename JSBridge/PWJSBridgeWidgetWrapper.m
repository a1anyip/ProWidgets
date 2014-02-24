//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWJSBridgeWidgetWrapper.h"
#import "PWJSBridgeWidgetItemWrapper.h"
#import "PWJSBridge.h"
#import "../PWWebRequest.h"
#import "../PWWebRequestFileFormData.h"
#import "../PWWidget.h"
#import "../PWWidgetItem.h"
#import "../PWContentItemViewController.h"
#import "../PWTheme.h"

#define PW_IMP_HANDLER(ivar,setName) - (JSValue *)ivar {\
	return [_##ivar value];\
}\
\
- (void)set##setName:(JSValue *)value {\
	PW_RELEASE_HANDLER(ivar)\
	_##ivar = [[JSManagedValue managedValueWithValue:value] retain];\
	[_bridge.context.virtualMachine addManagedReference:_##ivar withOwner:_bridge];\
}

#define PW_RELEASE_HANDLER(ivar) [_bridge.context.virtualMachine removeManagedReference:_##ivar withOwner:_bridge], [_##ivar release], _##ivar = nil;

@implementation PWJSBridgeWidgetWrapper

// Dismissal
- (void)maximize {
	[self.widget maximize];
}

- (void)minimize {
	[self.widget minimize];
}

- (void)dismiss {
	[self.widget dismiss];
}

// Loaders
- (BOOL)loadWidgetPlist:(JSValue *)filename {
	
	if ([filename isUndefined]) {
		[_bridge throwException:@"loadPlist: requires argument 1 (filename)."];
		return NO;
	}
	
	return [self.widget loadWidgetPlist:[filename toString]];
}

- (BOOL)loadThemePlist:(JSValue *)filename {
	
	if ([filename isUndefined]) {
		[_bridge throwException:@"loadThemePlist: requires argument 1 (filename)."];
		return NO;
	}
	
	return [self.widget loadThemePlist:[filename toString]];
}

// Getters
- (BOOL)isPresenting {
	return [self.widget isPresenting];
}

- (NSString *)name {
	return [self.widget name];
}

- (NSDictionary *)userInfo {
	return [self.widget userInfo];
}

// Setters

- (void)setPreferredTintColor:(JSValue *)value {
	
	if ([value isUndefined]) {
		[_bridge throwException:@"setPreferredTintColor: requires argument 1 (color string)."];
		return;
	}
	
	UIColor *color = nil;
	if ([value isString]) {
		NSString *string = [value toString];
		color = [PWTheme parseColorString:string];
	}
	
	[self.widget setPreferredTintColor:color];
}

- (void)setPreferredBarTextColor:(JSValue *)value {
	
	if ([value isUndefined]) {
		[_bridge throwException:@"setPreferredBarTextColor: requires argument 1 (color string)."];
		return;
	}
	
	UIColor *color = nil;
	if ([value isString]) {
		NSString *string = [value toString];
		color = [PWTheme parseColorString:string];
	}
	
	[self.widget setPreferredBarTextColor:color];
}

- (void)setShouldMaximizeContentHeight:(BOOL)value {
	[self.itemViewController setShouldMaximizeContentHeight:value];
}

- (void)setRequiresKeyboard:(BOOL)value {
	[self.itemViewController setRequiresKeyboard:value];
}

- (void)setTitle:(JSValue *)value {
	NSString *text = [value isString] ? [value toString] : @"";
	[self.itemViewController setTitle:text];
}

- (void)setCloseButtonText:(JSValue *)value {
	NSString *text = [value isUndefined] || [value isNull] ? @"" : [value toString];
	[self.itemViewController setCloseButtonText:text];
}

- (void)setActionButtonText:(JSValue *)value {
	NSString *text = [value isUndefined] || [value isNull] ? @"" : [value toString];
	[self.itemViewController setActionButtonText:text];
}

// items
- (JSValue *)items {
	NSMutableArray *itemWrappers = [NSMutableArray array];
	NSArray *items = [self.itemViewController items];
	for (PWWidgetItem *item in items) {
		PWJSBridgeWidgetItemWrapper *wrapper = [PWJSBridgeWidgetItemWrapper wrapperOfItem:item];
		if (wrapper != nil) {
			[itemWrappers addObject:wrapper];
		}
	}
	return [JSValue valueWithObject:itemWrappers inContext:_bridge.context];
}

- (void)setItems:(JSValue *)items {
	
	if (![items isObject]) {
		[self.itemViewController setItems:nil];
		return;
	}
	
	NSMutableArray *itemWrappers = [NSMutableArray array];
	NSArray *_items = [items toObjectOfClass:[NSArray class]];
	for (PWJSBridgeWidgetItemWrapper *item in _items) {
		PWWidgetItem *widgetItem = item.widgetItem;
		if (widgetItem != nil) {
			[itemWrappers addObject:widgetItem];
		}
	}
	
	[self.itemViewController setItems:itemWrappers];
}

- (void)setValue:(id)value forItem:(JSValue *)item {
	
	if ([item isUndefined]) {
		[_bridge throwException:@"setValue: requires two arguments (value and item)."];
		return;
	}
	
	PWJSBridgeWidgetItemWrapper *_item = [item toObjectOfClass:[PWJSBridgeWidgetItemWrapper class]];
	PWWidgetItem *_widgetItem = _item.widgetItem;
	[self.itemViewController setValue:value forItem:_widgetItem];
}

- (PWJSBridgeWidgetItemWrapper *)itemWithKey:(JSValue *)key {
	
	if ([key isUndefined]) {
		[_bridge throwException:@"itemWithKey: requires argument 1 (key)."];
		return nil;
	}
	
	PWWidgetItem *item = [self.itemViewController itemWithKey:[key toString]];
	return [PWJSBridgeWidgetItemWrapper wrapperOfItem:item];
}

- (PWJSBridgeWidgetItemWrapper *)itemAtIndex:(JSValue *)index {
	
	if ([index isUndefined]) {
		[_bridge throwException:@"itemAtIndex: requires argument 1 (index)."];
		return nil;
	}
	
	PWWidgetItem *item = [self.itemViewController itemAtIndex:[index toUInt32]];
	return [PWJSBridgeWidgetItemWrapper wrapperOfItem:item];
}

- (NSUInteger)indexOfItem:(JSValue *)item {
	
	if ([item isUndefined]) {
		[_bridge throwException:@"indexOfItem: requires argument 1 (item)."];
		return NSNotFound;
	}
	
	PWJSBridgeWidgetItemWrapper *_item = [item toObjectOfClass:[PWJSBridgeWidgetItemWrapper class]];
	PWWidgetItem *_widgetItem = _item.widgetItem;
	
	return [self.itemViewController indexOfItem:_widgetItem];
}

- (void)addItem:(JSValue *)item :(JSValue *)index :(JSValue *)animated {
	
	if ([item isUndefined]) {
		[_bridge throwException:@"addItem: requires argument 1 (item)."];
		return;
	}
	
	PWJSBridgeWidgetItemWrapper *_item = [item toObjectOfClass:[PWJSBridgeWidgetItemWrapper class]];
	PWWidgetItem *_widgetItem = _item.widgetItem;
	
	// only item
	if ([index isUndefined]) {
		return [self.itemViewController addItem:_widgetItem];
	}
	
	unsigned int _index = [index toUInt32];
	
	// only item and index
	if ([animated isUndefined]) {
		return [self.itemViewController addItem:_widgetItem atIndex:_index];
	}
	
	BOOL _animated = [animated toBool];
	[self.itemViewController addItem:_widgetItem atIndex:_index animated:_animated];
}

- (void)addItems:(JSValue *)items :(JSValue *)index :(JSValue *)animated {
	
	if ([items isUndefined]) {
		[_bridge throwException:@"addItems: requires argument 1 (items)."];
		return;
	}
	
	NSMutableArray *_widgetItems = [NSMutableArray array];
	for (PWJSBridgeWidgetItemWrapper *wrapper in [items toObjectOfClass:[NSArray class]]) {
		PWWidgetItem *_widgetItem = wrapper.widgetItem;
		if (_widgetItem != nil) {
			[_widgetItems addObject:_widgetItem];
		}
	}
	
	// only item
	if ([index isUndefined]) {
		return [self.itemViewController addItems:_widgetItems];
	}
	
	unsigned int _index = [index toUInt32];
	
	// only item and index
	if ([animated isUndefined]) {
		return [self.itemViewController addItems:_widgetItems atIndex:_index];
	}
	
	BOOL _animated = [animated toBool];
	[self.itemViewController addItems:_widgetItems atIndex:_index animated:_animated];
}

- (PWJSBridgeWidgetItemWrapper *)addItemNamed:(JSValue *)name :(JSValue *)index :(JSValue *)animated {
	
	if ([name isUndefined]) {
		[_bridge throwException:@"addItemNamed: requires argument 1 (name)."];
		return nil;
	}
	
	PWWidgetItem *widgetItem = nil;
	NSString *_itemName = [name toString];
	
	// only name
	if ([index isUndefined]) {
		widgetItem = [self.itemViewController addItemNamed:_itemName];
	} else {
		
		unsigned int _index = [index toUInt32];
		
		// only item and index
		if ([animated isUndefined]) {
			widgetItem = [self.itemViewController addItemNamed:_itemName atIndex:_index];
		} else {
			BOOL _animated = [animated toBool];
			widgetItem = [self.itemViewController addItemNamed:_itemName atIndex:_index animated:_animated];
		}
	}
	
	return [PWJSBridgeWidgetItemWrapper wrapperOfItem:widgetItem];
}

- (void)removeItem:(JSValue *)item :(JSValue *)animated {
	
	if ([item isUndefined]) {
		[_bridge throwException:@"removeItem: requires argument 1 (item)."];
		return;
	}
	
	PWJSBridgeWidgetItemWrapper *_item = [item toObjectOfClass:[PWJSBridgeWidgetItemWrapper class]];
	PWWidgetItem *widgetItem = _item.widgetItem;
	
	if ([animated isUndefined]) {
		[self.itemViewController removeItem:widgetItem];
		return;
	}
	
	BOOL _animated = [animated toBool];
	[self.itemViewController removeItem:widgetItem animated:_animated];
}

- (void)removeItemAtIndex:(JSValue *)index :(JSValue *)animated {
	
	if ([index isUndefined]) {
		[_bridge throwException:@"removeItemAtIndex: requires argument 1 (index)."];
		return;
	}
	
	unsigned int _index = [index toUInt32];
	
	if ([animated isUndefined]) {
		return [self.itemViewController removeItemAtIndex:_index];
	}
	
	BOOL _animated = [animated toBool];
	return [self.itemViewController removeItemAtIndex:_index animated:_animated];
}

// Helper methods
- (void)showMessage:(JSValue *)message :(JSValue *)title {
	
	if ([message isUndefined]) {
		[_bridge throwException:@"showMessage: requires argument 1 (message)."];
		return;
	}
	
	NSString *_message = [message toString];
	
	if ([title isUndefined]) {
		return [self.widget showMessage:_message];
	}
	
	NSString *_msgTitle = [title toString];
	return [self.widget showMessage:_message title:_msgTitle];
}

- (void)prompt:(JSValue *)message :(JSValue *)title :(JSValue *)buttonTitle :(JSValue *)defaultValue :(JSValue *)style :(JSValue *)completion {
	
	if ([message isUndefined]) {
		[_bridge throwException:@"prompt: requires argument 1 (message)."];
		return;
	}
	
	// message
	NSString *_message = [message isNull] ? @"" : [message toString];
	
	// title
	NSString *_title = nil;
	if (![title isUndefined] && ![title isNull]) {
		_title = [title toString];
	}
	
	// button title
	NSString *_buttonTitle = nil;
	if (![buttonTitle isUndefined] && ![buttonTitle isNull]) {
		_buttonTitle = [buttonTitle toString];
	}
	
	// default value
	NSString *_defaultValue = nil;
	if (![defaultValue isUndefined] && ![defaultValue isNull]) {
		_defaultValue = [defaultValue toString];
	}
	
	// style
	NSUInteger _style = [style toUInt32];
	if (_style > 3) _style = 0; // reset
	UIAlertViewStyle alertViewStyle = (UIAlertViewStyle)_style;
	
	// completion
	PWAlertViewCompletionHandler handler = nil;
	if ([completion isObject]) {
		
		__block JSManagedValue *completionValue = [[JSManagedValue managedValueWithValue:completion] retain];
		[_bridge.context.virtualMachine addManagedReference:completionValue withOwner:_bridge];
		
		handler = ^(BOOL cancelled, NSString *firstValue, NSString *secondValue) {
			if (completionValue != nil) {
				JSValue *callback = [completionValue value];
				if (callback != nil) {
					NSArray *arguments = nil;
					if (firstValue != nil && secondValue == nil) arguments = @[firstValue];
					else if (firstValue != nil && secondValue != nil) arguments = @[firstValue, secondValue];
					[callback callWithArguments:arguments];
				}
				[_bridge.context.virtualMachine removeManagedReference:completionValue withOwner:_bridge];
				[completionValue release], completionValue = nil;
			}
		};
	}
	
	[self.widget prompt:_message title:_title buttonTitle:_buttonTitle defaultValue:_defaultValue style:alertViewStyle completion:handler];
}

// Callbacks
PW_IMP_HANDLER(load, Load)
PW_IMP_HANDLER(willPresent, WillPresent)
PW_IMP_HANDLER(didPresent, DidPresent)
PW_IMP_HANDLER(willDismiss, WillDismiss)
PW_IMP_HANDLER(didDismiss, DidDismiss)
PW_IMP_HANDLER(configureFirstResponder, ConfigureFirstResponder)
PW_IMP_HANDLER(itemValueChangedEventHandler, ItemValueChangedEventHandler)
PW_IMP_HANDLER(submitEventHandler, SubmitEventHandler)

- (PWWidget *)base { return _bridge.widgetRef; }
- (PWWidget *)widget { return _bridge.widgetRef; }
- (PWContentItemViewController *)itemViewController { return _bridge.widgetRef.defaultItemViewController; }

- (void)dealloc {
	
	DEALLOCLOG;
	
	// release callbacks
	PW_RELEASE_HANDLER(load)
	PW_RELEASE_HANDLER(willPresent)
	PW_RELEASE_HANDLER(didPresent)
	PW_RELEASE_HANDLER(willDismiss)
	PW_RELEASE_HANDLER(didDismiss)
	PW_RELEASE_HANDLER(configureFirstResponder)
	PW_RELEASE_HANDLER(itemValueChangedEventHandler)
	PW_RELEASE_HANDLER(submitEventHandler)
	
	[super dealloc];
}

@end