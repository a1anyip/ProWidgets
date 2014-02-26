//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"
#import "PWThemableTableViewCell.h"

@interface PWWidgetRemindersTableViewCell : PWThemableTableViewCell {
	
	UIColor *_listColor;
	UIButton *_button;
}

- (void)setButtonReminder:(EKReminder *)reminder;
- (void)setButtonTarget:(id)target action:(SEL)action;

- (void)setTitle:(NSString *)title;
- (void)setAlarmDate:(NSDate *)alarmDate recurrenceRule:(EKRecurrenceRule *)recurrenceRule;
- (void)setListColor:(UIColor *)color;

@end