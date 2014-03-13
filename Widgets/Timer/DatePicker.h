//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "../../WidgetItems/item.h"

@interface PWWidgetTimerItemDatePicker : PWWidgetItem

@end

@interface PWWidgetTimerItemDatePickerCell : PWWidgetItemCell {
	
	UILabel *_timeLabel;
	UIDatePicker *_datePicker;
}

- (NSTimeInterval)countDownDuration;

- (void)showRemainingTime;
- (void)showDatePicker;

- (void)setRemainingTime:(NSTimeInterval)time;

@end