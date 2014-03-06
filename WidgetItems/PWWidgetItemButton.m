//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWWidgetItemButton.h"

@implementation PWWidgetItemButton

+ (Class)cellClass {
	return [PWWidgetItemButtonCell class];
}

- (BOOL)isSelectable {
	return YES;
}

- (void)select {
	NSString *actionEventName = self.actionEventName;
	if (actionEventName != nil) {
		[self.itemViewController triggerEvent:actionEventName withObject:self];
	}
}

@end

@implementation PWWidgetItemButtonCell

//////////////////////////////////////////////////////////////////////

+ (PWWidgetItemCellStyle)cellStyle {
	return PWWidgetItemCellStyleText;
}

//////////////////////////////////////////////////////////////////////

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier theme:(PWTheme *)theme {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier theme:theme])) {
		
		self.textLabel.textAlignment = NSTextAlignmentCenter;
		self.textLabel.textColor = [PWTheme systemBlueColor]; // default iOS 7 blue
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	self.textLabel.frame = self.contentView.bounds;
}

//////////////////////////////////////////////////////////////////////

- (void)setTitle:(NSString *)title {
	self.textLabel.text = title;
}

- (void)setIcon:(UIImage *)icon {
	self.imageView.image = icon;
}

- (void)setValue:(NSString *)value {}

//////////////////////////////////////////////////////////////////////

- (void)setTitleTextColor:(UIColor *)color {}

- (void)setSelectedTitleTextColor:(UIColor *)color {}

- (void)setButtonTextColor:(UIColor *)color {
	self.textLabel.textColor = color;
}

- (void)setSelectedButtonTextColor:(UIColor *)color {
	self.textLabel.highlightedTextColor = color;
}

@end