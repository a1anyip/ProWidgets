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

- (BOOL)isSelectable {
	return YES;
}

- (void)select {
	
	if (_recipientController == nil) {
		_recipientController = [[PWWidgetItemRecipientController alloc] initWithTitle:_titleWithoutColon delegate:self recipients:self.recipients type:_type forWidget:self.itemViewController.widget];
		RELEASE(_titleWithoutColon)
	}
	
	[self.itemViewController.widget pushViewController:_recipientController animated:YES];
}

- (void)setExtraAttributes:(NSDictionary *)attributes {
	
	NSString *recipientType = attributes[@"recipientType"];
	
	_type = PWWidgetItemRecipientTypePhoneContact; // default is phone contact
	
	if (recipientType != nil) {
		NSString *typeString = [recipientType lowercaseString];
		if ([typeString isEqualToString:@"phone"]) {
			_type = PWWidgetItemRecipientTypePhoneContact;
		} else if ([typeString isEqualToString:@"mail"]) {
			_type = PWWidgetItemRecipientTypeMailContact;
		}
	}
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
	
	[super setValue:value];
	
	if (_recipientController != nil) {
		NSMutableArray *recipients = [NSMutableArray array];
		for (NSDictionary *value in self.value) {
			MFComposeRecipient *recipient = value[@"recipient"];
			if (recipient != nil && ![recipients containsObject:recipient]) {
				[recipients addObject:recipient];
			}
		}
		[_recipientController setRecipients:recipients];
	}
}

- (NSArray *)addresses {
	NSMutableArray *addresses = [NSMutableArray array];
	for (NSDictionary *value in self.value) {
		NSString *address = value[@"address"];
		if (address != nil) {
			[addresses addObject:address];
		}
	}
	return addresses;
}

- (void)setAddresses:(NSArray *)addresses {
	CKRecipientGenerator *generator = [CKRecipientGenerator sharedRecipientGenerator];
	NSMutableArray *recipients = [NSMutableArray array];
	for (NSString *address in addresses) {
		id recipient = [generator recipientWithAddress:address];
		if (recipient != nil && ![recipients containsObject:recipient]) {
			[recipients addObject:recipient];
		}
	}
	[self setRecipients:recipients];
}

- (void)addAddress:(NSString *)address {
	
	if (address == nil) return;
	
	NSMutableArray *addresses = (NSMutableArray *)self.addresses;
	if (![addresses containsObject:address]) {
		[addresses addObject:address];
		[self setAddresses:addresses];
	}
}

- (void)removeAddress:(NSString *)address {
	
	if (address == nil) return;
	
	NSMutableArray *addresses = (NSMutableArray *)self.addresses;
	if ([addresses containsObject:address]) {
		[addresses removeObject:address];
		[self setAddresses:addresses];
	}
}

- (NSArray *)recipients {
	NSMutableArray *recipients = nil;
	if (_recipientController == nil) {
		recipients = [NSMutableArray array];
		for (NSDictionary *value in self.value) {
			MFComposeRecipient *recipient = value[@"recipient"];
			if (recipient != nil && ![recipients containsObject:recipient]) {
				[recipients addObject:recipient];
			}
		}
	} else {
		recipients = [[_recipientController.recipients mutableCopy] autorelease];
	}
	return recipients == nil ? [NSMutableArray array] : recipients;
}

- (void)setRecipients:(NSArray *)recipients {
	
	if (![recipients isKindOfClass:[NSArray class]]) return;
	
	NSMutableArray *itemValue = [NSMutableArray array];
	for (MFComposeRecipient *recipient in recipients) {
		if (![recipient isKindOfClass:[MFComposeRecipient class]]) continue;
		NSString *name = recipient.compositeName;
		NSString *address = recipient.rawAddress; // no space
		NSString *formattedAddress = recipient.address; // formatted
		if (name == nil) name = @"";
		if (address == nil) address = @"";
		if (formattedAddress == nil) formattedAddress = @"";
		[itemValue addObject:@{ @"name": name, @"address": address, @"formattedAddress": formattedAddress, @"recipient": recipient }];
	}
	
	if (_recipientController != nil) {
		[_recipientController setRecipients:recipients];
	}
	
	[super setValue:itemValue];
}

- (void)addRecipient:(MFComposeRecipient *)recipient {
	
	if (recipient == nil) return;
	
	NSMutableArray *recipients = (NSMutableArray *)self.recipients;
	if (![recipients containsObject:recipient]) {
		[recipients addObject:recipient];
		[self setRecipients:recipients];
	}
}

- (void)removeRecipient:(MFComposeRecipient *)recipient {
	
	if (recipient == nil) return;
	
	NSMutableArray *recipients = (NSMutableArray *)self.recipients;
	if ([recipients containsObject:recipient]) {
		[recipients removeObject:recipient];
		[self setRecipients:recipients];
	}
}

- (void)recipientsChanged:(NSArray *)recipients {
	
	// update value
	NSDictionary *oldValue = [[self.value copy] autorelease];
	[self setRecipients:recipients];
	
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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier theme:(PWTheme *)theme {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier theme:theme])) {
		
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
	NSArray *recipients = [(PWWidgetItemRecipient *)self.item recipients];
	NSString *text = [PWWidgetItemRecipientController displayTextForRecipients:recipients maxWidth:maxWidth font:font];
	self.detailTextLabel.text = text;
	[self setNeedsLayout]; // this line is important to instantly reflect the new value
}

- (BOOL)shouldShowChevron {
	return YES;
}

@end