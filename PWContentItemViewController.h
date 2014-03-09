//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"
#import "PWContentViewController.h"

@interface PWContentItemViewController : PWContentViewController<UITableViewDelegate, UITableViewDataSource> {
	
	BOOL _itemsShouldFillHeight;
	CGFloat _fillHeight;
	NSString *_overrideContentHeightExpressionForPortrait;
	NSString *_overrideContentHeightExpressionForLandscape;
	NSMutableArray *_items;
	
	BOOL _shouldUpdateLastFirstResponder;
	PWWidgetItem *_lastFirstResponder;
	PWWidgetItem *_pendingFirstResponder;
	
	void(^_wrappedItemValueChangedEventBlockHandler)(PWWidgetItem *, id);
}

@property(nonatomic, readonly) UITableView *tableView;
@property(nonatomic, copy) NSArray *items;

@property(nonatomic, readonly) BOOL shouldUpdateLastFirstResponder;
@property(nonatomic, readonly) PWWidgetItem *lastFirstResponder;

+ (NSString *)itemValueChangedEventName;
+ (NSString *)submitEventName;

- (BOOL)loadPlist:(NSString *)filename;

// helper methods to set handlers
- (void)setItemValueChangedEventHandler:(id)target selector:(SEL)selector;
- (void)setItemValueChangedEventBlockHandler:(void(^)(PWWidgetItem *, id))block;
- (void)setSubmitEventHandler:(id)target selector:(SEL)selector;
- (void)setSubmitEventBlockHandler:(void(^)(id))block;

- (void)reload;
- (void)configureFirstResponder;
- (void)requestFirstResponder:(PWWidgetItem *)item;
- (BOOL)updateLastFirstResponder:(PWWidgetItem *)item;
- (void)setNextResponder:(PWWidgetItem *)currentFirstResponder;
- (void)itemValueChanged:(PWWidgetItem *)item oldValue:(id)oldValue;
- (void)reloadCellOfItem:(PWWidgetItem *)item;

- (NSString *)overrideContentHeightExpressionForOrientation:(PWWidgetOrientation)orientation;
- (void)setOverrideContentHeightExpression:(NSString *)expression;
- (void)setOverrideContentHeightExpression:(NSString *)expression forOrientation:(PWWidgetOrientation)orientation;

- (CGFloat)optimalContentHeightForOrientation:(PWWidgetOrientation)orientation;

// items
- (NSArray *)items;

// set value
- (void)setValue:(id)value forItem:(PWWidgetItem *)item;

// retrieve item
- (PWWidgetItem *)itemWithKey:(NSString *)key;
- (PWWidgetItem *)itemAtIndex:(NSUInteger)index;
- (NSUInteger)indexOfItem:(PWWidgetItem *)item;

// update items
- (void)setItems:(NSArray *)items;

// addition
- (void)addItem:(PWWidgetItem *)item;
- (void)addItem:(PWWidgetItem *)item atIndex:(NSUInteger)index;
- (void)addItem:(PWWidgetItem *)item animated:(BOOL)animated;
- (void)addItem:(PWWidgetItem *)item atIndex:(NSUInteger)index animated:(BOOL)animated;

- (void)addItems:(NSArray *)items;
- (void)addItems:(NSArray *)items atIndex:(NSUInteger)index;
- (void)addItems:(NSArray *)items animated:(BOOL)animated;
- (void)addItems:(NSArray *)items atIndex:(NSUInteger)index animated:(BOOL)animated;

- (PWWidgetItem *)addItemNamed:(NSString *)name;
- (PWWidgetItem *)addItemNamed:(NSString *)name atIndex:(NSUInteger)index;
- (PWWidgetItem *)addItemNamed:(NSString *)name animated:(BOOL)animated;
- (PWWidgetItem *)addItemNamed:(NSString *)name atIndex:(NSUInteger)index animated:(BOOL)animated;

// removal
- (void)removeItem:(PWWidgetItem *)item;
- (void)removeItem:(PWWidgetItem *)item animated:(BOOL)animated;
- (void)removeItemAtIndex:(NSUInteger)index;
- (void)removeItemAtIndex:(NSUInteger)index animated:(BOOL)animated;

// private method
- (BOOL)_checkBounds:(NSUInteger)index;

@end