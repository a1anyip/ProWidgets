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
	return [NSMutableArray array];
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
		_recipientController.delegate = self;
		RELEASE(_titleWithoutColon)
	}
	
	[_recipientController setRecipients:self.value];
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

- (void)setValue:(NSArray *)value {
	
	if (![value isKindOfClass:[NSArray class]]) return;
	
	[_value release];
	_value = [value copy];
	
	if (_recipientController != nil) {
		[_recipientController setRecipients:_value];
	}
	
	[super setValue:value];
}

- (NSArray *)recipients {
	return (NSArray *)self.value;
}

- (void)setRecipients:(NSArray *)recipients {
	[self setValue:recipients];
}

- (void)addRecipient:(MFComposeRecipient *)recipient {
	if (_recipientController == nil) {
		if (![self.value containsObject:recipient])
			[self.value addObject:recipient];
	} else {
		[_recipientController addRecipient:recipient]; // this will also trigger the value change in this instance
	}
}

- (void)removeRecipient:(MFComposeRecipient *)recipient {
	if (_recipientController == nil) {
		[self.value removeObject:recipient];
	} else {
		[_recipientController removeRecipient:recipient]; // this will also trigger the value change in this instance
	}
}

- (void)recipientsChanged:(NSArray *)recipients {
	
	// update value
	NSDictionary *oldValue = [[self.value copy] autorelease];
	[super setValue:recipients];
	
	LOG(@"PWWidgetItemRecipient: recipientsChanged: (new: %@, old: %@)", self.value, oldValue);
	
	// notify widget
	[self.itemViewController itemValueChanged:self oldValue:oldValue];
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
	CGFloat maxWidth = self.detailTextLabel.bounds.size.width;
	UIFont *font = self.detailTextLabel.font;
	NSString *text = [PWWidgetItemRecipientController displayTextForRecipients:value maxWidth:maxWidth font:font];
	self.detailTextLabel.text = text;
	[self setNeedsLayout]; // this line is important to instantly reflect the new value
}

- (BOOL)shouldShowChevron {
	return YES;
}

@end