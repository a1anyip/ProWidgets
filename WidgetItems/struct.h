//  ProWidgets
//  Copyright 2014 Alan Yip. All rights reserved.

typedef NS_ENUM(NSUInteger, TonePickerType) {
	TonePickerTypeBoth = 1,
	TonePickerTypeOnlyAlertTone = 2,
	TonePickerTypeOnlyRingTone = 3
};

typedef NS_ENUM(NSUInteger, ToneType) {
	ToneTypeRingtone = 1,
	ToneTypeMediaItem = 2
};

typedef NS_ENUM(NSUInteger, PWWidgetItemRecipientType) {
	PWWidgetItemRecipientTypeMessageContact,
	PWWidgetItemRecipientTypeMailContact,
};