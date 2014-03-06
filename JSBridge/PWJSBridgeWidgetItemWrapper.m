//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWJSBridgeWidgetItemWrapper.h"
#import "PWJSBridge.h"
#import "../PWController.h"
#import "../PWWebRequest.h"
#import "../PWWebRequestFileFormData.h"
#import "../PWWidget.h"
#import "../PWWidgetItem.h"
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

#define PW_IMP_ITEM_WRAPPER(name,setName,type,toType) - (JSValue *)name {\
	return [JSValue valueWith##toType:_widgetItem.name inContext:_bridge.context];\
}\
\
- (void)set##setName:(JSValue *)value {\
	_widgetItem.name = [value to##toType];\
}

#define PW_IMP_ITEM_STRING_WRAPPER(name,setName) - (JSValue *)name {\
	return [JSValue valueWithObject:_widgetItem.name inContext:_bridge.context];\
}\
\
- (void)set##setName:(JSValue *)value {\
	_widgetItem.name = [value isUndefined] || [value isNull] ? nil : [value toString];\
}

#define PW_RELEASE_HANDLER(ivar) [_bridge.context.virtualMachine removeManagedReference:_##ivar withOwner:_bridge], [_##ivar release], _##ivar = nil;

@implementation PWJSBridgeWidgetItemWrapper

+ (instancetype)wrapperOfItem:(PWWidgetItem *)item {
	
	if (item == nil) return nil;
	
	PWJSBridgeWidgetItemWrapper *wrapper = [self new];
	wrapper.widgetItem = item;
	
	// set handler
	[item setItemValueChangedEventBlockHandler:^(id oldValue) {
		
		JSValue *callback = wrapper.itemValueChangedEventHandler;
		if (callback != nil) {
			NSArray *arguments = nil;
			if (oldValue != nil) arguments = @[oldValue];
			[callback callWithArguments:arguments];
		}
	}];
	
	return [wrapper autorelease];
}

- (PWWidgetCellType)cellType {
	return _widgetItem.cellType;
}

- (NSString *)type {
	return _widgetItem.type;
}

PW_IMP_ITEM_WRAPPER(overrideHeight, OverrideHeight, double, Double)
PW_IMP_ITEM_WRAPPER(hideChevron, HideChevron, BOOL, Bool)

PW_IMP_ITEM_STRING_WRAPPER(key, Key)
PW_IMP_ITEM_STRING_WRAPPER(title, Title)
PW_IMP_ITEM_STRING_WRAPPER(actionEventName, ActionEventName)

// Callbacks
PW_IMP_HANDLER(itemValueChangedEventHandler, ItemValueChangedEventHandler)

- (void)setIcon:(JSValue *)icon {
	
	UIImage *_icon = nil;
	NSString *filename = [icon isUndefined] || [icon isNull] ? nil : [icon toString];
	
	if (filename != nil && [filename length] > 0) {
		PWWidget *widget = _widgetItem.widget;
		_icon = [widget imageNamed:filename];
	}
	
	[_widgetItem setIcon:_icon];
}

- (void)dealloc {
	
	DEALLOCLOG;
	
	// release callbacks
	PW_RELEASE_HANDLER(itemValueChangedEventHandler)
	
	// release widget item
	RELEASE(_widgetItem)
	
	[super dealloc];
}

@end