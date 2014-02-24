//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"

@protocol PWContentListViewControllerDelegate <NSObject>

// data source
- (NSArray *)listItemTitles;
- (NSArray *)listItemValues;
- (NSArray *)selectedValues;

// configuration
@optional
- (NSInteger)noneIndex;
@optional
- (NSUInteger)maximumNumberOfSelection;

// callback when user is trying to select more items than limitation
@optional
- (void)selectedTooManyItems;

// callback when selected items are changed
//- (void)selectedItemsChanged:(NSArray *)selectedItems;
- (void)selectedValuesChanged:(NSArray *)newValues oldValues:(NSArray *)oldValues;

@end