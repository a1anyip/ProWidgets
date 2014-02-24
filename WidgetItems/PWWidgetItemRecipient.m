//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWWidgetItemRecipient.h"

@implementation PWWidgetItemRecipient

+ (Class)valueClass {
	return [NSArray class];
}

+ (id)defaultValue {
	return [NSArray array];
}

+ (Class)cellClass {
	return [PWWidgetItemRecipientCell class];
}

- (instancetype)init {
	if ((self = [super init])) {
		
	}
	return self;
}

- (BOOL)isSelectable {
	return YES;
}

- (void)select {
	
	if (_recipientController == nil) {
		_recipientController = [PWWidgetItemRecipientController new];
		_recipientController.title = _titleWithoutColon;
		RELEASE(_titleWithoutColon)
	}
	
	[[PWController activeWidget] pushViewController:_recipientController animated:YES];
}

- (void)setTitle:(NSString *)title {
	[super setTitle:title];
	
	[_titleWithoutColon release];
	
	if ([title hasSuffix:@":"]) {
		_titleWithoutColon = [[title substringToIndex:[title length] - 1] copy]; // remove the colon
	} else {
		_titleWithoutColon = [title copy];
	}
	
	if (_recipientController != nil) {
		_recipientController.title = _titleWithoutColon;
		RELEASE(_titleWithoutColon)
	}
}

- (void)dealloc {
	RELEASE(_recipientController)
	RELEASE(_titleWithoutColon)
	[super dealloc];
}

@end

@implementation PWWidgetItemRecipientCell

//////////////////////////////////////////////////////////////////////

+ (PWWidgetItemCellStyle)cellStyle {
	return PWWidgetItemCellStyleValue;
}

//////////////////////////////////////////////////////////////////////

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		
		self.detailTextLabel.textAlignment = NSTextAlignmentLeft;
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	UILabel *title = self.textLabel;
	UILabel *value = self.detailTextLabel;
	
	[title sizeToFit];
	CGRect titleRect = title.frame;
	CGRect valueRect = value.frame;
	
	CGFloat difference = valueRect.origin.x - titleRect.origin.x - titleRect.size.width - 10.0;
	valueRect.origin.x -= difference;
	valueRect.size.width += difference;
	
	value.frame = valueRect;
}

- (void)setTitle:(NSString *)title {
	self.textLabel.text = title;
}

- (void)setValue:(NSArray *)value {
	self.detailTextLabel.text = @"0 recipients";
	[self setNeedsLayout]; // this line is important to instantly reflect the new value
}

- (BOOL)shouldShowChevron {
	return YES;
}

@end