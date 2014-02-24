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

@interface PWWidgetCalendarTableViewCell : PWThemableTableViewCell {
	
	UIView *_separator;
	
	UILabel *_titleLabel;
	UILabel *_locationLabel;
	UILabel *_startTimeLabel;
	UILabel *_endTimeLabel;
}

- (void)setTitle:(NSString *)title;
- (void)setLocation:(NSString *)location;
- (void)setStartDate:(NSDate *)startDate endDate:(NSDate *)endDate allDay:(BOOL)allDay;
- (void)setCalendarColor:(UIColor *)color;

@end