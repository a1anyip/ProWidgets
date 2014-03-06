//
//  ProWidgets
//  Google Authenticator
//
//  Created by Alan Yip on 22 Feb 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "Cell.h"
#import "Reminders.h"
#import "PWTheme.h"

char PWWidgetRemindersTableViewCellReminderKey;

@implementation PWWidgetRemindersTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier theme:(PWTheme *)theme {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier theme:theme])) {
		// button
		_button = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		_button.adjustsImageWhenHighlighted = NO;
		_button.showsTouchWhenHighlighted = NO;
		[self.contentView addSubview:_button];
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGSize size = self.bounds.size;
	CGFloat width = size.width;
	CGFloat height = size.height;
	CGFloat buttonWidth = 30.0;
	CGFloat buttonHeight = 50.0;
	CGFloat padding = 10.0;
	
	CGRect textLabelRect = self.textLabel.frame;
	CGRect detailTextLabelRect = self.detailTextLabel.frame;
	
	_button.frame = CGRectMake(padding, (height - buttonHeight) / 2, buttonWidth, buttonHeight);
	
	textLabelRect.origin.x = buttonWidth + padding * 2;
	textLabelRect.size.width = width - (buttonWidth + padding * 3);
	
	detailTextLabelRect.origin.x = buttonWidth + padding * 2;
	detailTextLabelRect.size.width = width - (buttonWidth + padding * 3);
	
	self.textLabel.frame = textLabelRect;
	self.detailTextLabel.frame = detailTextLabelRect;
}

- (void)setButtonReminder:(EKReminder *)reminder {
	if (_button != nil) {
		objc_setAssociatedObject(_button, &PWWidgetRemindersTableViewCellReminderKey, reminder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
}

- (void)setButtonTarget:(id)target action:(SEL)action {
	[_button removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
	[_button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

- (void)setTitle:(NSString *)title {
	self.textLabel.text = title;
}

- (void)setAlarmDate:(NSDate *)alarmDate recurrenceRule:(EKRecurrenceRule *)recurrenceRule {
	
	NSString *dateText = nil;
	NSString *repeatText = nil;
	
	// convert date to readable string
	dateText = [[PWWidgetReminders widget] parseDate:alarmDate allDay:NO shortForm:YES];
	
	// convert recurrence rule to string
	EKRecurrenceFrequency frequency = recurrenceRule.frequency;
	NSInteger interval = recurrenceRule.interval;
	if (interval == 1) {
		switch (frequency) {
			case EKRecurrenceFrequencyDaily:
				repeatText = @"Daily";
				break;
			case EKRecurrenceFrequencyWeekly:
				repeatText = @"Weekly";
				break;
			case EKRecurrenceFrequencyMonthly:
				repeatText = @"Monthly";
				break;
			case EKRecurrenceFrequencyYearly:
				repeatText = @"Yearly";
				break;
		}
	} else if (interval == 2) {
		switch (frequency) {
			case EKRecurrenceFrequencyWeekly:
				repeatText = @"Biweekly";
				break;
			default:
				break;
		}
	}
	
	NSString *resultText = [NSString stringWithFormat:@"%@%@%@", dateText, (repeatText != nil ? @", " : @""), (repeatText != nil ? repeatText : @"")];
	self.detailTextLabel.text = resultText;
}

- (void)setListColor:(UIColor *)color {
	
	PWWidgetReminders *widget = [PWWidgetReminders widget];
	
	if (_listColor == nil || ![_listColor isEqual:color]) {
		[_listColor release];
		_listColor = [color retain];
		
		UIColor *darkerColor = [PWTheme darkenColor:color];
		
		// retrieve the images
		UIImage *normal = [widget imageNamed:@"buttonNormal"];
		UIImage *pressed = [widget imageNamed:@"buttonPressed"];
		
		// tint the images
		normal = [PWTheme tintImage:normal withColor:darkerColor];
		pressed = [PWTheme tintImage:pressed withColor:darkerColor];
		
		// configure the button
		[_button setImage:normal forState:UIControlStateNormal];
		[_button setImage:pressed forState:UIControlStateHighlighted];
	}
}

- (void)dealloc {
	RELEASE(_listColor)
	RELEASE_VIEW(_button)
	[super dealloc];
}

@end