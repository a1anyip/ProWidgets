//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"
#import "PWThemableTableViewCell.h"

@interface PWWidgetItemCell : PWThemableTableViewCell {
	
	PWWidgetItem *_item;
}

@property(nonatomic, readonly) PWWidgetItem *item;

//////////////////////////////////////////////////////////////////////

+ (PWWidgetItemCellStyle)cellStyle;
+ (instancetype)create;

//////////////////////////////////////////////////////////////////////

/**
 * Override this method to update delegates of
 * some UI elements
 **/

- (void)updateItem:(PWWidgetItem *)item;

//////////////////////////////////////////////////////////////////////

/**
 * Override these methods to update appearance
 * Change only appearance, no any callback
 **/

- (void)setTitle:(NSString *)title;
- (void)setIcon:(UIImage *)icon;
- (void)setValue:(id)value;

//////////////////////////////////////////////////////////////////////

/**
 * Override these methods to configure the cell
 **/

- (void)willAppear;

- (BOOL)contentCanBecomeFirstResponder;
- (void)contentSetFirstResponder;
- (void)contentResignFirstResponder;

- (BOOL)shouldShowChevron;

//////////////////////////////////////////////////////////////////////

- (void)_setItem:(PWWidgetItem *)item;

@end