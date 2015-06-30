//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWWidgetItemCell.h"

@implementation PWWidgetItemCell

//////////////////////////////////////////////////////////////////////

+ (PWWidgetItemCellStyle)cellStyle {
	return PWWidgetItemCellStyleNone;
}

+ (instancetype)create:(PWTheme *)theme {
	
	PWWidgetItemCellStyle style = [self cellStyle];
	UITableViewCellStyle cellStyle;
	
	switch (style) {
		case PWWidgetItemCellStyleNone:
		default:
			cellStyle = UITableViewCellStyleDefault;
			break;
		case PWWidgetItemCellStyleText:
			cellStyle = UITableViewCellStyleDefault;
			break;
		case PWWidgetItemCellStyleValue:
			cellStyle = UITableViewCellStyleValue1;
			break;
	}
	
	return [[[self alloc] initWithStyle:cellStyle reuseIdentifier:NSStringFromClass(self) theme:theme] autorelease];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	// re-position the title label
	CGRect labelRect = self.textLabel.frame;
	labelRect.origin.x = PWDefaultItemCellPadding;
	self.textLabel.frame = labelRect;
}

//////////////////////////////////////////////////////////////////////

/**
 * Override this method to update delegates of
 * some UI elements
 **/

- (void)updateItem:(PWWidgetItem *)item {}

//////////////////////////////////////////////////////////////////////

/**
 * Override these methods to update appearance
 * Change only appearance, no any callback
 **/

- (void)setTitle:(NSString *)title {}

- (void)setIcon:(UIImage *)icon {}

- (void)setValue:(id)value {}

//////////////////////////////////////////////////////////////////////

/**
 * Override these methods to configure the cell
 **/

- (void)willAppear {}

+ (BOOL)contentCanBecomeFirstResponder { return NO; }
- (void)contentSetFirstResponder {}
- (void)contentResignFirstResponder {}

- (BOOL)shouldShowChevron { return NO; }

//////////////////////////////////////////////////////////////////////

- (void)_setItem:(PWWidgetItem *)item {
	_item = item;
	[self updateItem:item];
}

//////////////////////////////////////////////////////////////////////

- (void)dealloc {
	
	DEALLOCLOG;
	
	_item = nil;
	[super dealloc];
}

@end