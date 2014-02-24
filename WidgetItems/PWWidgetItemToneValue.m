//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWWidgetItemToneValue.h"
#import "../PWController.h"
#import "../PWWidget.h"
#import "../PWWidgetItem.h"

@implementation PWWidgetItemTonePickerController

+ (NSString *)nameOfToneWithIdentifier:(NSString *)toneIdentifier andType:(ToneType)toneType {
	
	TLToneManager *toneManager = [TLToneManager sharedRingtoneManager];
	NSString *toneName = [[toneManager copyNameOfIdentifier:toneIdentifier isValid:NULL] autorelease];
	
	return toneName;
}

+ (TonePickerType)tonePickerTypeFromNumber:(NSNumber *)number {
	switch ([number unsignedIntegerValue]) {
		case (NSUInteger)TonePickerTypeBoth:
		default:
			return TonePickerTypeBoth;
		case (NSUInteger)TonePickerTypeOnlyAlertTone:
			return TonePickerTypeOnlyAlertTone;
		case (NSUInteger)TonePickerTypeOnlyRingTone:
			return TonePickerTypeOnlyRingTone;
	}
}

+ (ToneType)toneTypeFromNumber:(NSNumber *)number {
	return [number unsignedIntegerValue] == (NSUInteger)ToneTypeMediaItem ? ToneTypeMediaItem : ToneTypeRingtone;
}

- (instancetype)init {
	if ((self = [super init])) {
		self.automaticallyAdjustsScrollViewInsets = NO;
		self.requiresKeyboard = NO;
		self.shouldMaximizeContentHeight = YES;
	}
	return self;
}

- (instancetype)initWithTonePickerType:(TonePickerType)tonePickerType selectedToneIdentifier:(NSString *)identifier toneType:(ToneType)toneType {
	if ((self = [self init])) {
		
		_tonePickerType = tonePickerType;
		
		// set selected tone identifier
		if (identifier != nil) {
			if (toneType == ToneTypeRingtone)
				[_tonePicker setSelectedRingtoneIdentifier:identifier];
			else if (toneType == ToneTypeMediaItem)
				[_tonePicker setSelectedMediaIdentifier:identifier];
		}
	}
	return self;
}

- (void)loadView {
	
	_tonePicker = nil;
	
	switch (_tonePickerType) {
		case TonePickerTypeBoth:
		default:
			_tonePicker = [[objc_getClass("TKTonePicker") alloc] initWithFrame:CGRectZero avController:nil filter:31 tonePicker:YES];
			[_tonePicker setShowsMedia:YES];
			[_tonePicker setMediaAtTop:YES];
			break;
		case TonePickerTypeOnlyAlertTone:
			_tonePicker = [[objc_getClass("TKTonePicker") alloc] initWithFrame:CGRectZero avController:nil filter:31 tonePicker:YES];
			[_tonePicker setShowsMedia:NO];
			break;
		case TonePickerTypeOnlyRingTone:
			_tonePicker = [[objc_getClass("TKTonePicker") alloc] initWithFrame:CGRectZero avController:nil filter:0 tonePicker:YES];
			[_tonePicker setShowsMedia:YES];
			[_tonePicker setMediaAtTop:YES];
			break;
	}
	
	[_tonePicker setShowsNone:YES];
	_tonePicker.delegate = self;
	
	self.view = _tonePicker;
}

- (NSString *)title {
	return @"Sound";
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
	if (parent == nil) {
		// ask tone picker to stop playing selected ringtone
		[_tonePicker stopPlayingWithFadeOut:YES];
	}
}

- (void)ringtonePicker:(TKTonePicker *)picker selectedRingtoneWithIdentifier:(NSString *)identifier {
	LOG(@"ringtonePicker:selectedRingtoneWithIdentifier: <identifier: %@>", identifier);
	
	if ([identifier isKindOfClass:[NSNumber class]]) {
		identifier = [(NSNumber *)identifier stringValue];
	}
	
	self.selectedToneIdentifier = identifier;
	self.selectedToneType = ToneTypeRingtone;
	
	// notify delegate
	[_delegate selectedToneIdentifierChanged:identifier toneType:ToneTypeRingtone];
}

- (void)ringtonePicker:(TKTonePicker *)picker selectedMediaItemWithIdentifier:(NSString *)identifier {
	LOG(@"ringtonePicker:selectedMediaItemWithIdentifier: <identifier: %@>", identifier);
	
	if ([identifier isKindOfClass:[NSNumber class]]) {
		identifier = [(NSNumber *)identifier stringValue];
	}
	
	self.selectedToneIdentifier = identifier;
	self.selectedToneType = ToneTypeMediaItem;
	
	// notify delegate
	[_delegate selectedToneIdentifierChanged:identifier toneType:ToneTypeMediaItem];
}

- (void)dealloc {
	// ask tone picker to stop playing selected ringtone
	[_tonePicker stopPlayingWithFadeOut:YES];
	[super dealloc];
}

@end

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
		_tonePickerController = [[PWWidgetItemTonePickerController alloc] initWithTonePickerType:_tonePickerType selectedToneIdentifier:_selectedToneIdentifier toneType:_selectedToneType];
		_tonePickerController.delegate = self;
	}
	
	[[PWController activeWidget] pushViewController:_tonePickerController animated:YES];
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
	[self setValue:@{ @"identifier":identifier, @"type":@(toneType) }];
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
	
	if (toneIdentifier == nil) {
		self.detailTextLabel.text = @"None";
	} else {
		self.detailTextLabel.text = [PWWidgetItemTonePickerController nameOfToneWithIdentifier:toneIdentifier andType:toneType];
	}
	
	[self setNeedsLayout]; // this line is important to instantly reflect the new value
}

- (BOOL)shouldShowChevron {
	return YES;
}

@end