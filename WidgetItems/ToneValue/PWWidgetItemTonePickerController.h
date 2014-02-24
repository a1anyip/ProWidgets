//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "../item.h"
#import "../../PWContentViewController.h"

typedef NS_ENUM(NSUInteger, TonePickerType) {
	TonePickerTypeBoth = 1,
	TonePickerTypeOnlyAlertTone = 2,
	TonePickerTypeOnlyRingTone = 3
};

typedef NS_ENUM(NSUInteger, ToneType) {
	ToneTypeRingtone = 1,
	ToneTypeMediaItem = 2
};

@protocol PWWidgetItemTonePickerControllerDelegate <NSObject>

@required
- (void)selectedToneIdentifierChanged:(NSString *)identifier toneType:(ToneType)toneType;

@end

@interface PWWidgetItemTonePickerController : PWContentViewController {
	
	id<PWWidgetItemTonePickerControllerDelegate> _delegate;
	BOOL _originalSetting;
	
	TKTonePicker *_tonePicker;
	TonePickerType _tonePickerType;
	NSString *_selectedToneIdentifier;
	ToneType _selectedToneType;
}

@property(nonatomic, assign) id<PWWidgetItemTonePickerControllerDelegate> delegate;
@property(nonatomic, copy) NSString *selectedToneIdentifier;
@property(nonatomic) ToneType selectedToneType;

+ (NSString *)nameOfToneWithIdentifier:(NSString *)toneIdentifier andType:(ToneType)toneType;
+ (ToneType)toneTypeFromNumber:(NSNumber *)number;
+ (TonePickerType)tonePickerTypeFromNumber:(NSNumber *)number;

- (instancetype)initWithTonePickerType:(TonePickerType)tonePickerType selectedToneIdentifier:(NSString *)identifier toneType:(ToneType)toneType;

@end