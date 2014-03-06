//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWWidgetItemTonePickerController.h"
#import "../PWWidgetItemToneValue.h"
#import "../../PWController.h"
#import "../../PWWidget.h"
#import "../../PWWidgetItem.h"

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

- (instancetype)initWithTonePickerType:(TonePickerType)tonePickerType selectedToneIdentifier:(NSString *)identifier toneType:(ToneType)toneType forWidget:(PWWidget *)widget {
	if ((self = [super initForWidget:widget])) {
		
		self.automaticallyAdjustsScrollViewInsets = NO;
		self.requiresKeyboard = NO;
		self.shouldMaximizeContentHeight = YES;
		
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