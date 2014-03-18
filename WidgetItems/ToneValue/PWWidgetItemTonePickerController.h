//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "../item.h"
#import "../PWWidgetItemToneValue.h"
#import "../../PWContentViewController.h"
#import "PWWidgetItemTonePickerControllerDelegate.h"

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

- (instancetype)initWithTonePickerType:(TonePickerType)tonePickerType selectedToneIdentifier:(NSString *)identifier toneType:(ToneType)toneType forWidget:(PWWidget *)widget;

- (TKTonePicker *)tonePicker;

@end