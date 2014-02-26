//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWWidgetItemDateValue.h"
#import "../PWWidget.h"
#import "../PWWidgetItem.h"

@implementation PWWidgetItemDateValue

+ (Class)valueClass {
	return [NSDate class];
}

+ (id)defaultValue {
	return [NSDate date];
}

+ (Class)cellClass {
	return [PWWidgetItemDateValueCell class];
}

- (instancetype)init {
	if ((self = [super init])) {
		[self setValue:[NSDate date]];
	}
	return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
	
	PWWidgetItemDateValue *item = (PWWidgetItemDateValue *)[super copyWithZone:zone];
	
	item.hideDateText = self.hideDateText;
	item.hideTimeText = self.hideTimeText;
	item.datePickerMode = self.datePickerMode;
	item.minuteInterval = self.minuteInterval;
	
	return item;
}

- (BOOL)isSelectable {
	return YES;
}

- (void)select {
	[self becomeFirstResponder];
}

- (void)setExtraAttributes:(NSDictionary *)attributes {
	
	// hideDateText
	NSNumber *hideDateText = attributes[@"hideDateText"];
	self.hideDateText = [hideDateText boolValue];
	
	// hideTimeText
	NSNumber *hideTimeText = attributes[@"hideMinuteText"];
	self.hideTimeText = [hideTimeText boolValue];
	
	// date picker mode
	NSString *mode = [attributes[@"dateMode"] lowercaseString];
	if ([mode hasSuffix:@"dateandtime"] || [mode hasSuffix:@"datetime"]) {
		self.datePickerMode = UIDatePickerModeDateAndTime;
	} else if ([mode hasSuffix:@"time"]) {
		self.datePickerMode = UIDatePickerModeTime;
	} else {
		self.datePickerMode = UIDatePickerModeDate;
	}
	
	// minute interval
	NSNumber *minuteInterval = attributes[@"dateMinuteInterval"];
	self.minuteInterval = MIN(MAX(1, [minuteInterval unsignedIntegerValue]), 30);
}

- (void)setHideDateText:(BOOL)hide {
	_hideDateText = hide;
	[self setCellValue:self.value];
}

- (void)setHideTimeText:(BOOL)hide {
	_hideTimeText = hide;
	[self setCellValue:self.value];
}

- (void)setDatePickerMode:(UIDatePickerMode)mode {
	PWWidgetItemDateValueCell *cell = (PWWidgetItemDateValueCell *)self.activeCell;
	cell.datePicker.datePickerMode = mode;
	cell.datePicker.minuteInterval = _minuteInterval; // minute interval will change after updating date picker mode
	_datePickerMode = mode;
	// force to update minute interval and date picker mode
	[self setValue:self.value];
}

- (void)setMinuteInterval:(NSUInteger)minuteInterval {
	PWWidgetItemDateValueCell *cell = (PWWidgetItemDateValueCell *)self.activeCell;
	cell.datePicker.minuteInterval = minuteInterval;
	_minuteInterval = minuteInterval;
	// force to update minute interval and date picker mode
	[self setValue:self.value];
}

- (NSDate *)processDate:(NSDate *)date {
	
	if (date == nil) return [NSDate date];
	
	NSUInteger minuteInterval = MIN(MAX(1, _minuteInterval), 30);
	NSTimeInterval startsTime = floor([date timeIntervalSinceReferenceDate] / 60.0 / minuteInterval) * 60.0 * minuteInterval;
	return [NSDate dateWithTimeIntervalSinceReferenceDate:startsTime];
}

- (void)setValue:(NSDate *)date {
	[super setValue:[self processDate:date]];
}

- (void)datePickerValueChanged:(UIDatePicker *)sender {
	
	LOG(@"PWWidgetItemDateValue: datePickerValueChanged: %@", sender.date);
	
	NSDate *oldValue = [[self.value copy] autorelease];
	
	// update value in item
	NSDate *date = [self processDate:sender.date];
	[self setValue:date];
	
	// notify item view controller
	[self.itemViewController itemValueChanged:self oldValue:oldValue];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	
	PWWidgetItemDateValueCell *cell = (PWWidgetItemDateValueCell *)self.activeCell;
	
	// select the cell
	cell.selected = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	
	PWWidgetItemDateValueCell *cell = (PWWidgetItemDateValueCell *)self.activeCell;
	
	// deselect the cell
	cell.selected = NO;
}

- (void)dealloc {
	[super dealloc];
}

@end

static NSDateFormatter *dateFormatter = nil;

@implementation PWWidgetItemDateValueCell

//////////////////////////////////////////////////////////////////////

+ (PWWidgetItemCellStyle)cellStyle {
	return PWWidgetItemCellStyleValue;
}

//////////////////////////////////////////////////////////////////////

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		
		// create a date formatter
		if (dateFormatter == nil) {
			dateFormatter = [NSDateFormatter new];
			[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
		}
		
		// create a date picker
		_datePicker = [UIDatePicker new];
		_datePicker.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		
		// create a text field
		_textField = [UITextField new];
		_textField.inputView = _datePicker;
		[self.contentView addSubview:_textField];
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	// text field
	_textField.frame = CGRectZero;
}

- (void)willAppear {
	
	self.selected = [_textField isFirstResponder];
	
	PWWidgetItemDateValue *item = (PWWidgetItemDateValue *)self.item;
	_datePicker.datePickerMode = [item datePickerMode];
	_datePicker.minuteInterval = [item minuteInterval];
}

//////////////////////////////////////////////////////////////////////

- (void)setTitle:(NSString *)title {
	self.textLabel.text = title;
}

- (void)setValue:(NSDate *)value {
	
	// update the value in date picker
	[_datePicker setDate:value animated:NO];
	
	PWWidgetItemDateValue *item = (PWWidgetItemDateValue *)self.item;
	BOOL hideDateText = item.hideDateText;
	BOOL hideTimeText = item.hideTimeText;
	UIDatePickerMode mode = [item datePickerMode];
	
	if (mode == UIDatePickerModeTime) {
		// only time
		[dateFormatter setDateStyle:NSDateFormatterNoStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	} else if (mode == UIDatePickerModeDate) {
		// only date
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle]; // changed from long to medium
		[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	} else if (mode == UIDatePickerModeDateAndTime) {
		// date and time
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle]; // changed from long to medium
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	}
	
	if (hideDateText) [dateFormatter setDateStyle:NSDateFormatterNoStyle];
	if (hideTimeText) [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	
	self.detailTextLabel.text = [dateFormatter stringFromDate:value];
}

+ (BOOL)contentCanBecomeFirstResponder {
	return YES;
}

- (void)contentSetFirstResponder {
	if (_textField.superview != nil) {
		// set selected
		self.selected = YES;
		// correct the date in date picker
		[_datePicker setDate:[NSDate distantFuture] animated:NO]; // this is to fix a weird bug in iOS 7
		[_datePicker setDate:(NSDate *)self.item.value animated:NO];
		// show the date picker
		[_textField becomeFirstResponder];
	}
}

//////////////////////////////////////////////////////////////////////

- (void)updateItem:(PWWidgetItem *)item {
	
	[_datePicker removeTarget:nil action:NULL forControlEvents:UIControlEventValueChanged];
	[_datePicker addTarget:item action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
	
	_textField.delegate = (PWWidgetItemDateValue *)item;
}

- (void)dealloc {
	
	RELEASE_VIEW(_textField)
	RELEASE(_datePicker)
	
	[super dealloc];
}

@end