//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "item.h"

@interface PWWidgetItemDateValue : PWWidgetItem<UITextFieldDelegate> {
	
	BOOL _hideDateText;
	BOOL _hideTimeText;
	UIDatePickerMode _datePickerMode;
	NSUInteger _minuteInterval;
}

@property(nonatomic) BOOL hideDateText;
@property(nonatomic) BOOL hideTimeText;
@property(nonatomic) UIDatePickerMode datePickerMode;
@property(nonatomic) NSUInteger minuteInterval;

@end

@interface PWWidgetItemDateValueCell : PWWidgetItemCell {
	
	UIDatePicker *_datePicker;
	UITextField *_textField;
}

@property(nonatomic, readonly) UIDatePicker *datePicker;

@end