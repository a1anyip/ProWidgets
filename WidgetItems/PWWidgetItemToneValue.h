//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "item.h"
#import "../PWContentViewController.h"
#import "ToneValue/PWWidgetItemTonePickerController.h"

@interface PWWidgetItemToneValue : PWWidgetItem<PWWidgetItemTonePickerControllerDelegate> {
	
	PWWidgetItemTonePickerController *_tonePickerController;
	
	TonePickerType _tonePickerType;
	NSString *_selectedToneIdentifier;
	ToneType _selectedToneType;
}

@property(nonatomic) TonePickerType tonePickerType;
@property(nonatomic, readonly) NSString *selectedToneIdentifier;
@property(nonatomic, readonly) ToneType selectedToneType;

- (void)setSelectedToneIdentifier:(NSString *)identifier toneType:(ToneType)toneType;

@end

@interface PWWidgetItemToneValueCell : PWWidgetItemCell

@end