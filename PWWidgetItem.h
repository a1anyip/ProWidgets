//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"

@interface PWWidgetItem : NSObject<NSCopying> {
	
	/////////////////////////////
	///// Runtime variables /////
	/////////////////////////////
	
	PWContentItemViewController *_itemViewController;
	PWWidgetItemCell *_activeCell;
	id _value;
	void(^_itemValueChangedEventBlockHandler)(id);
	
	//////////////////////
	///// Properties /////
	//////////////////////
	
	PWWidgetCellType _cellType;
	NSString *_key;
	NSString *_title;
	NSString *_actionEventName;
	BOOL _hideChevron;
	UIImage *_icon;
	
	BOOL _shouldFillHeight;
	CGFloat _overrideHeight;
}

@property(nonatomic, assign) PWContentItemViewController *itemViewController;
@property(nonatomic, assign) PWWidgetItemCell *activeCell;

// basic properties
@property(nonatomic, readonly) PWWidgetCellType cellType;
@property(nonatomic, readonly) NSString *type;
@property(nonatomic, copy) NSString *key;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *actionEventName;
@property(nonatomic) BOOL hideChevron;
@property(nonatomic, retain) UIImage *icon;
@property(nonatomic) BOOL shouldFillHeight;
@property(nonatomic) CGFloat overrideHeight;

// value
@property(nonatomic, retain) id value;
@property(nonatomic, copy) void(^itemValueChangedEventBlockHandler)(id);

+ (Class)valueClass;
+ (id)defaultValue;

//////////////////////////////////////////////////////////////////////

/**
 * Override this to specify which class the cell should be
 **/

+ (Class)cellClass;

/**
 * Retrieve the identifier of table view cell
 **/

+ (NSString *)cellIdentifier;

/**
 * Retrieve the table view cell for a widget item
 **/

+ (PWWidgetItemCell *)createCell;

//////////////////////////////////////////////////////////////////////

/**
 * Shortcuts related to widget items
 **/

+ (PWWidgetItem *)createItemNamed:(NSString *)name forItemViewController:(PWContentItemViewController *)itemViewController;

//////////////////////////////////////////////////////////////////////

/**
 * Initialization
 **/

- (instancetype)initWithKey:(NSString *)key title:(NSString *)title actionEventName:(NSString *)actionEventName hideChevron:(BOOL)hideChevron icon:(UIImage *)icon;

//////////////////////////////////////////////////////////////////////

/**
 * Override these methods to configure the item
 **/

- (BOOL)shouldAutoDeselect;
- (BOOL)isSelectable;
- (void)select;

- (void)becomeFirstResponder;
- (void)setExtraAttributes:(NSDictionary *)attributes;
- (CGFloat)cellHeightForOrientation:(PWWidgetOrientation)orientation;

//////////////////////////////////////////////////////////////////////

- (void)setItemValue:(id)value;
- (void)setCellValue:(id)value;

@end