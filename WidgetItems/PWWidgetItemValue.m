//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWWidgetItemValue.h"

@implementation PWWidgetItemValue

+ (Class)cellClass {
	return [PWWidgetItemValueCell class];
}

- (BOOL)isSelectable {
	return NO;
}

@end

@implementation PWWidgetItemValueCell

+ (PWWidgetItemCellStyle)cellStyle {
	return PWWidgetItemCellStyleValue;
}

- (void)setTitle:(NSString *)title {
	self.textLabel.text = title;
}

- (void)setValue:(NSString *)value {
	self.detailTextLabel.text = value;
}

@end