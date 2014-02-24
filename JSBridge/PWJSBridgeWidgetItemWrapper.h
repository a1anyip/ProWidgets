//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWJSBridgeWrapper.h"
#import "../PWWidgetItem.h"

@protocol PWJSBridgeWidgetItemWrapperExport <JSExport>

// getter
@property(nonatomic, readonly) PWWidgetCellType cellType;
@property(nonatomic, readonly) NSString *type;

// getter and setter
@property(nonatomic, retain) JSValue *key;
@property(nonatomic, retain) JSValue *title;
@property(nonatomic, retain) JSValue *actionEventName;
@property(nonatomic, retain) JSValue *hideChevron;
@property(nonatomic, retain) JSValue *overrideHeight;

// callbacks
@property(nonatomic, retain) JSValue *itemValueChangedEventHandler;

- (void)setIcon:(JSValue *)image;

@end

@interface PWJSBridgeWidgetItemWrapper : PWJSBridgeWrapper<PWJSBridgeWidgetItemWrapperExport> {
	
	PWWidgetItem *_widgetItem;
	
	JSManagedValue *_itemValueChangedEventHandler;
}

@property(nonatomic, retain) PWWidgetItem *widgetItem;

// callbacks
@property(nonatomic, retain) JSValue *itemValueChangedEventHandler;

+ (instancetype)wrapperOfItem:(PWWidgetItem *)item;

@end