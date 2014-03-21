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

@property(nonatomic, readonly) BOOL shouldUpdateLastFirstResponder;
@property(nonatomic, readonly) PWWidgetItem *lastFirstResponder;

/**
 *  Retrieve the event name for item value changed event.
 *
 *  @return The event name for item value changed event.
 */
+ (NSString *)itemValueChangedEventName;

/**
 *  Retrieve the event name for submit event.
 *
 *  @return The event name for submit event.
 */
+ (NSString *)submitEventName;

/**
 *  Load the item definitions from a plist file for this item view controller.
 *
 *  @param filename The name of the plist file.
 *
 *  @return Return YES if the plist file is loaded; otherwise, return NO.
 */
- (BOOL)loadPlist:(NSString *)filename;

/**
 *  A shortcut to set the event handler for item value changed event.
 *
 *  @param target   The handler receiver.
 *  @param selector The handler selector.
 */
- (void)setItemValueChangedEventHandler:(id)target selector:(SEL)selector;

/**
 *  A shortcut to set the event handler for item value changed event with a block.
 *
 *  @param block The handler block.
 */
- (void)setItemValueChangedEventBlockHandler:(void(^)(PWWidgetItem *, id))block;

/**
 *  A shortcut to set the event handler for submit event.
 *
 *  @param target   The handler receiver.
 *  @param selector The handler selector.
 */
- (void)setSubmitEventHandler:(id)target selector:(SEL)selector;

/**
 *  A shortcut to set the event handler for submit event.
 *
 *  @param block The handler receiver.
 */
- (void)setSubmitEventBlockHandler:(void(^)(id))block;

/**
 *  Ask the table view of this item view controller to reload.
 */
- (void)reload;

/**
 *  Override this method to configure the first responder.
 *  The default implementation will make the first suitable item to become the first responder.
 */
- (void)configureFirstResponder;

/**
 *  Use this method to make an item to become the first responder.
 *
 *  @param item The item to be the first responder.
 */
- (void)requestFirstResponder:(PWWidgetItem *)item;
- (BOOL)updateLastFirstResponder:(PWWidgetItem *)item;
- (void)setNextResponder:(PWWidgetItem *)currentFirstResponder;
- (void)itemValueChanged:(PWWidgetItem *)item oldValue:(id)oldValue;
- (void)reloadCellOfItem:(PWWidgetItem *)item;

/**
 *  Retrieve the overiride content height expression for a specified orientation.
 *
 *  @param orientation The orientation.
 *
 *  @return The override content height expression.
 */
- (NSString *)overrideContentHeightExpressionForOrientation:(PWWidgetOrientation)orientation;

/**
 *  Set the override content height expression for both orientations.
 *
 *  @param expression The new override content height expression.
 */
- (void)setOverrideContentHeightExpression:(NSString *)expression;

/**
 *  Set the override content height expression for a specified orientation.
 *
 *  @param expression  The new override content height expression.
 *  @param orientation The orientation.
 */
- (void)setOverrideContentHeightExpression:(NSString *)expression forOrientation:(PWWidgetOrientation)orientation;

/**
 *  Retrieve the optimal content height for a specified orientation.
 *  This calculates the optimal content height according to the items and the available height on your screen.
 *
 *  @param orientation The orientation.
 *
 *  @return The optimal content height.
 */
- (CGFloat)optimalContentHeightForOrientation:(PWWidgetOrientation)orientation;

/**
 *  Retrieve all the items.
 *
 *  @return An array of all the items.
 */
- (NSArray *)items;

/**
 *  Set the value for a specified item.
 *
 *  @param value The new value.
 *  @param item  The item.
 */
- (void)setValue:(id)value forItem:(PWWidgetItem *)item;

/**
 *  Retrieve an existing item with a key.
 *
 *  @param key The key of an item.
 *
 *  @return Return the item if the item with a specified key can be found; otherwise, return nil.
 */
- (PWWidgetItem *)itemWithKey:(NSString *)key;

/**
 *  Retrieve an existing item at an index.
 *
 *  @param index The index of an item.
 *
 *  @return Return the item if the item at a specified index can be found; otherwise, return nil.
 */
- (PWWidgetItem *)itemAtIndex:(NSUInteger)index;

/**
 *  Retrieve the index of a specified item.
 *
 *  @param item The item.
 *
 *  @return Return the index of the item if the item is associated with this item view controller; otherwise, return NSNotFound.
 */
- (NSUInteger)indexOfItem:(PWWidgetItem *)item;

/**
 *  Set all the items at once.
 *
 *  @param items An array of all the items.
 */
- (void)setItems:(NSArray *)items;

/**
 *  Add a new item to the end of the list without animations.
 *
 *  @param item The item to be added.
 */
- (void)addItem:(PWWidgetItem *)item;

/**
 *  Add a new item to the specified index of the list without animations.
 *
 *  @param item  The item to be added.
 *  @param index The index.
 */
- (void)addItem:(PWWidgetItem *)item atIndex:(NSUInteger)index;

/**
 *  Add a new item to the end of the list.
 *
 *  @param item     The item to be added.
 *  @param animated If YES, the item will be added to the list using an animation.
 */
- (void)addItem:(PWWidgetItem *)item animated:(BOOL)animated;

/**
 *  Add a new item to the list.
 *
 *  @param item     The item to be added.
 *  @param index    The index.
 *  @param animated If YES, the item will be added to the list using an animation.
 */
- (void)addItem:(PWWidgetItem *)item atIndex:(NSUInteger)index animated:(BOOL)animated;

/**
 *  Add an array of items to the list to the end of the list without animations.
 *
 *  @param items An array of items to be added.
 */
- (void)addItems:(NSArray *)items;

/**
 *  Add an array of items to the list to the specified index of the list without animations.
 *
 *  @param items An array of items to be added.
 *  @param index The index.
 */
- (void)addItems:(NSArray *)items atIndex:(NSUInteger)index;

/**
 *  Add an array of items to the end of the list using an animation.
 *
 *  @param items    An array of items to be added.
 *  @param animated If YES, the items will be added to the list using an animation.
 */
- (void)addItems:(NSArray *)items animated:(BOOL)animated;

/**
 *  Add an array of items to the specified index of the list.
 *
 *  @param items    An array of items to be added.
 *  @param index    The index.
 *  @param animated If YES, the items will be added to the list using an animation.
 */
- (void)addItems:(NSArray *)items atIndex:(NSUInteger)index animated:(BOOL)animated;

/**
 *  Create and add a new item with the specified item name to the end of the list without animations.
 *
 *  @param name The item name.
 *
 *  @return Return the item instance if it has been created and added successfully; otherwise, return nil.
 */
- (PWWidgetItem *)addItemNamed:(NSString *)name;

/**
 *  Create and add a new item with the specified item name to the specified index of the list without animations.
 *
 *  @param name  The item name.
 *  @param index The index.
 *
 *  @return Return the item instance if it has been created and added successfully; otherwise, return nil.
 */
- (PWWidgetItem *)addItemNamed:(NSString *)name atIndex:(NSUInteger)index;

/**
 *  Create and add a new item with the specified item name to the end of the list.
 *
 *  @param name     The item name.
 *  @param animated If YES, the item will be added to the list using an animation.
 *
 *  @return Return the item instance if it has been created and added successfully; otherwise, return nil.
 */
- (PWWidgetItem *)addItemNamed:(NSString *)name animated:(BOOL)animated;

/**
 *  Create and add a new item with the specified item name to the specified index of the list.
 *
 *  @param name     The item name.
 *  @param index    The index.
 *  @param animated If YES, the item will be added to the list using an animation.
 *
 *  @return Return the item instance if it has been created and added successfully; otherwise, return nil.
 */
- (PWWidgetItem *)addItemNamed:(NSString *)name atIndex:(NSUInteger)index animated:(BOOL)animated;

/**
 *  Remove the specified item from the list without animations.
 *
 *  @param item The item to be removed.
 */
- (void)removeItem:(PWWidgetItem *)item;

/**
 *  Remove the specified item from the list.
 *
 *  @param item     The item to be removed.
 *  @param animated If YES, the item will be removed from the list using an animation.
 */
- (void)removeItem:(PWWidgetItem *)item animated:(BOOL)animated;

/**
 *  Remove an item at the specified index from the list without animations.
 *
 *  @param index The index.
 */
- (void)removeItemAtIndex:(NSUInteger)index;

/**
 *  Remove an item at the specified index from the list.
 *
 *  @param index    The index.
 *  @param animated If YES, the item will be removed from the list using an animation.
 */
- (void)removeItemAtIndex:(NSUInteger)index animated:(BOOL)animated;

// private method
- (BOOL)_checkBounds:(NSUInteger)index;

@end