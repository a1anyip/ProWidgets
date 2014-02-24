//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "item.h"
#import "../PWContentListViewControllerDelegate.h"

@interface PWWidgetItemListValue : PWWidgetItem<PWContentListViewControllerDelegate> {
	
	PWContentListViewController *_listViewController;
	NSMutableArray *_listItemTitles;
	NSMutableArray *_listItemValues;
	NSInteger _noneIndex;
	NSUInteger _maximumNumberOfSelection;
}

@property(nonatomic, readonly) NSArray *listItemTitles;
@property(nonatomic, readonly) NSArray *listItemValues;
@property(nonatomic) NSInteger noneIndex;
@property(nonatomic) NSUInteger maximumNumberOfSelection;

- (void)setListItemTitles:(NSArray *)titles values:(NSArray *)values;
- (NSString *)displayTextForValues:(NSArray *)values;

@end

@interface PWWidgetItemListValueCell : PWWidgetItemCell

@end