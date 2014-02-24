//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWWidgetItemSwitch.h"

@implementation PWWidgetItemSwitch

+ (Class)valueClass {
	return [NSNumber class];
}

+ (id)defaultValue {
	return @NO;
}

+ (Class)cellClass {
	return [PWWidgetItemSwitchCell class];
}

- (void)switchValueChanged:(UISwitch *)sender {
	
	NSNumber *oldValue = [[self.value copy] autorelease];
	
	BOOL isOn = [sender isOn];
	NSNumber *value = [NSNumber numberWithBool:isOn];
	[self setItemValue:value];
	
	// notify the item view controller
	[self.itemViewController itemValueChanged:self oldValue:oldValue];
}

@end

@implementation PWWidgetItemSwitchCell

//////////////////////////////////////////////////////////////////////

+ (PWWidgetItemCellStyle)cellStyle {
	return PWWidgetItemCellStyleText;
}

//////////////////////////////////////////////////////////////////////

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		
		_switch = [UISwitch new];
		[self.contentView addSubview:_switch];
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGSize size = self.contentView.bounds.size;
	CGFloat width = size.width;
	CGFloat height = size.height;
	
	CGSize switchSize = _switch.bounds.size;
	CGFloat switchWidth = switchSize.width;
	CGFloat switchHeight = switchSize.height;
	
	CGFloat left = width - switchWidth - PWDefaultItemCellPadding;
	CGFloat top = (height - switchHeight) / 2;
	
	_switch.frame = CGRectMake(left, top, switchWidth, switchHeight);
}

//////////////////////////////////////////////////////////////////////

- (void)updateItem:(PWWidgetItem *)item {
	
	// remove all previous targets
	[_switch removeTarget:nil action:NULL forControlEvents:UIControlEventValueChanged];
	
	// add the new delegate as the only target
	[_switch addTarget:item action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
}

//////////////////////////////////////////////////////////////////////

- (void)setTitle:(NSString *)title {
	self.textLabel.text = title;
}

- (void)setValue:(NSString *)value {
	
	if (value != nil && ![value isKindOfClass:[NSNumber class]]) {
		LOG(@"PWWidgetItemSwitch: Unsupported value type (%@)", value);
		return;
	}
	
	[_switch setOn:[value boolValue] animated:NO];
}

- (void)setSwitchOnColor:(UIColor *)color {
	_switch.onTintColor = color;
}

- (void)setSwitchOffColor:(UIColor *)color {
	_switch.tintColor = color;
}

//////////////////////////////////////////////////////////////////////

- (void)dealloc {
	RELEASE_VIEW(_switch)
	[super dealloc];
}

@end