//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "DatePicker.h"
#import "../../PWWidget.h"

@implementation PWWidgetTimerItemDatePicker

+ (Class)cellClass {
	return [PWWidgetTimerItemDatePickerCell class];
}

- (CGFloat)cellHeightForOrientation:(PWWidgetOrientation)orientation {
	return 162.0;
}

@end

@implementation PWWidgetTimerItemDatePickerCell

//////////////////////////////////////////////////////////////////////

+ (PWWidgetItemCellStyle)cellStyle {
	return PWWidgetItemCellStyleNone;
}

//////////////////////////////////////////////////////////////////////

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier theme:(PWTheme *)theme {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier theme:theme])) {
		
		_timeLabel = [UILabel new];
		_timeLabel.alpha = 0.0;
		_timeLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:60.0];
		_timeLabel.textAlignment = NSTextAlignmentCenter;
		_timeLabel.text = @"00:00";
		[self.contentView addSubview:_timeLabel];
		
		_datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, 0, 162.0)];
		_datePicker.datePickerMode = UIDatePickerModeCountDownTimer;
		[self.contentView addSubview:_datePicker];
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	_timeLabel.frame = self.contentView.bounds;
	_datePicker.frame = self.contentView.bounds;
}

- (NSTimeInterval)countDownDuration {
	return _datePicker.countDownDuration;
}

- (void)showRemainingTime {
	[UIView animateWithDuration:.2 animations:^{
		_datePicker.alpha = 0.0;
		_timeLabel.alpha = 1.0;
	}];
}

- (void)showDatePicker {
	[UIView animateWithDuration:.2 animations:^{
		_datePicker.alpha = 1.0;
		_timeLabel.alpha = 0.0;
	}];
}

- (void)setRemainingTime:(NSTimeInterval)time {
	
	NSUInteger hour = floor(time / 60.0 / 60.0);
	NSUInteger minute = floor(time / 60.0) - hour * 60;
	NSUInteger second = time - minute * 60 - hour * 60 * 60;
	
	NSString *text;
	if (hour == 0) {
		text = [NSString stringWithFormat:@"%02d:%02d", (int)minute, (int)second];
	} else {
		text = [NSString stringWithFormat:@"%02d:%02d:%02d", (int)hour, (int)minute, (int)second];
	}
	
	_timeLabel.text = text;
}

- (void)dealloc {
	RELEASE_VIEW(_timeLabel)
	RELEASE_VIEW(_datePicker)
	[super dealloc];
}

@end