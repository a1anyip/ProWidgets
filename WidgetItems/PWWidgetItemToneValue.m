//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWWidgetItemToneValue.h"
#import "ToneValue/PWWidgetItemTonePickerController.h"
#import "../PWController.h"
#import "../PWWidget.h"
#import "../PWWidgetItem.h"

@implementation PWWidgetItemToneValue

+ (Class)cellClass {
	return [PWWidgetItemToneValueCell class];
}

- (instancetype)copyWithZone:(NSZone *)zone {
	
	PWWidgetItemToneValue *item = (PWWidgetItemToneValue *)[super copyWithZone:zone];
	[item setSelectedToneIdentifier:_selectedToneIdentifier toneType:_selectedToneType];
	
	return item;
}

- (void)setValue:(NSDictionary *)value {
	
	if (value == nil) {
		// reset
		RELEASE(_selectedToneIdentifier)
		_selectedToneType = ToneTypeRingtone;
		return;
	}
	
	if (![value isKindOfClass:[NSDictionary class]]) return;
	
	NSString *identifier = value[@"identifier"];
	NSNumber *type = value[@"type"];
	
	if (identifier == nil || type == nil) return;
	
	[_selectedToneIdentifier release];
	_selectedToneIdentifier = [identifier copy];
	_selectedToneType = [PWWidgetItemTonePickerController toneTypeFromNumber:type];
	
	[super setValue:value];
}

- (BOOL)isSelectable {
	return YES;
}

- (void)select {
	
	if (_tonePickerController == nil) {
		_tonePickerController = [[PWWidgetItemTonePickerController alloc] initWithTonePickerType:_tonePickerType selectedToneIdentifier:_selectedToneIdentifier toneType:_selectedToneType forWidget:self.itemViewController.widget];
		_tonePickerController.delegate = self;
	}
	
	[self.itemViewController.widget pushViewController:_tonePickerController animated:YES];
}

- (void)setExtraAttributes:(NSDictionary *)attributes {
	
	NSString *tonePickerType = [attributes[@"tonePickerType"] lowercaseString];
	NSString *selectedToneIdentifier = attributes[@"selectedToneIdentifier"];
	NSNumber *selectedToneType = attributes[@"selectedToneType"];
	
	if ([tonePickerType hasSuffix:@"alerttone"])
		_tonePickerType = TonePickerTypeOnlyAlertTone;
	else if ([tonePickerType hasSuffix:@"ringtone"])
		_tonePickerType = TonePickerTypeOnlyRingTone;
	else
		_tonePickerType = TonePickerTypeBoth;
	
	ToneType toneType = [PWWidgetItemTonePickerController toneTypeFromNumber:selectedToneType];
	
	if (selectedToneIdentifier != nil && selectedToneType != nil)
		[self setSelectedToneIdentifier:selectedToneIdentifier toneType:toneType];
}

- (void)setTonePickerType:(TonePickerType)type {
	if (_tonePickerController != nil) {
		LOG(@"PWWidgetItemToneValue: tone picker type cannot be changed because the picker was created.");
		return;
	}
	_tonePickerType = type;
}

- (void)setSelectedToneIdentifier:(NSString *)identifier toneType:(ToneType)toneType {
	if (identifier == nil) {
		[self setValue:nil];
	} else {
		[self setValue:@{ @"identifier":identifier, @"type":@(toneType) }];
	}
}

- (void)selectedToneIdentifierChanged:(NSString *)identifier toneType:(ToneType)toneType {
	
	NSString *toneIdentifier = identifier == nil ? @"" : identifier;
	
	// update value
	NSDictionary *oldValue = [[self.value copy] autorelease];
	[self setSelectedToneIdentifier:toneIdentifier toneType:toneType];
	
	LOG(@"PWWidgetItemToneValue: selectedToneIdentifierChanged:toneType: (new: %@, old: %@)", self.value, oldValue);
	
	// notify widget
	[self.itemViewController itemValueChanged:self oldValue:oldValue];
}

- (void)dealloc {
	RELEASE(_tonePickerController)
	RELEASE(_selectedToneIdentifier)
	[super dealloc];
}

@end

@implementation PWWidgetItemToneValueCell

//////////////////////////////////////////////////////////////////////

+ (PWWidgetItemCellStyle)cellStyle {
	return PWWidgetItemCellStyleValue;
}

//////////////////////////////////////////////////////////////////////

- (void)setTitle:(NSString *)title {
	self.textLabel.text = title;
}

- (void)setValue:(NSDictionary *)value {
	
	NSString *toneIdentifier = value[@"identifier"];
	ToneType toneType = [PWWidgetItemTonePickerController toneTypeFromNumber:value[@"type"]];
	
	if (toneIdentifier == nil || [toneIdentifier length] == 0) {
		self.detailTextLabel.text = CT(@"ToneValueNone");
	} else {
		self.detailTextLabel.text = [PWWidgetItemTonePickerController nameOfToneWithIdentifier:toneIdentifier andType:toneType];
	}
	
	[self setNeedsLayout]; // this line is important to instantly reflect the new value
}

- (BOOL)shouldShowChevron {
	return YES;
}

@end