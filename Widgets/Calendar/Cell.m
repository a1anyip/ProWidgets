//
//  ProWidgets
//  Google Authenticator
//
//  Created by Alan Yip on 22 Feb 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "Cell.h"
#import "Calendar.h"
#import "PWTheme.h"

@implementation PWWidgetCalendarTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier theme:(PWTheme *)theme {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier theme:theme])) {
		
		// separator
		_separator = [UIView new];
		[self.contentView addSubview:_separator];
		
		// title label
		_titleLabel = [UILabel new];
		_titleLabel.backgroundColor = [UIColor clearColor];
		_titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
		[self.contentView addSubview:_titleLabel];
		
		// location label
		_locationLabel = [UILabel new];
		_locationLabel.backgroundColor = [UIColor clearColor];
		_locationLabel.font = [UIFont systemFontOfSize:14.0];
		[self.contentView addSubview:_locationLabel];
		
		// start time label
		_startTimeLabel = [UILabel new];
		_startTimeLabel.textAlignment = NSTextAlignmentRight;
		_startTimeLabel.backgroundColor = [UIColor clearColor];
		_startTimeLabel.font = [UIFont systemFontOfSize:13.0];
		[self.contentView addSubview:_startTimeLabel];
		
		// end time label
		_endTimeLabel = [UILabel new];
		_endTimeLabel.textAlignment = NSTextAlignmentRight;
		_endTimeLabel.backgroundColor = [UIColor clearColor];
		_endTimeLabel.font = [UIFont systemFontOfSize:13.0];
		[self.contentView addSubview:_endTimeLabel];
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGSize size = self.bounds.size;
	CGFloat width = size.width;
	CGFloat height = size.height;
	CGFloat horizontalPadding = 8.0;
	
	CGFloat separatorWidth = 2.0;
	CGFloat timeWidth = 60.0;
	
	CGFloat labelHeight = 22.0;
	CGFloat contentHeight = labelHeight * 2;
	CGFloat top = (height - contentHeight) / 2;
	
	CGRect separatorRect = CGRectMake(horizontalPadding * 2 + timeWidth, 0, separatorWidth, height);
	
	CGRect startTimeRect = CGRectMake(horizontalPadding, top, timeWidth, labelHeight);
	CGRect endTimeRect = startTimeRect;
	endTimeRect.origin.y += labelHeight;
	
	CGRect titleRect = CGRectMake(horizontalPadding * 3 + timeWidth + separatorWidth, top, 0.0, labelHeight);
	titleRect.size.width = width - titleRect.origin.x - horizontalPadding;
	
	CGRect locationRect = CGRectMake(horizontalPadding * 3 + timeWidth + separatorWidth, top + labelHeight, 0.0, labelHeight);
	locationRect.size.width = width - locationRect.origin.x - horizontalPadding;
	
	_separator.frame = separatorRect;
	_titleLabel.frame = titleRect;
	_locationLabel.frame = locationRect;
	_startTimeLabel.frame = startTimeRect;
	_endTimeLabel.frame = endTimeRect;
}

- (void)setTitle:(NSString *)title {
	_titleLabel.text = title;
}

- (void)setLocation:(NSString *)location {
	_locationLabel.text = location;
}

- (void)setStartDate:(NSDate *)startDate endDate:(NSDate *)endDate allDay:(BOOL)allDay {
	
	if (allDay) {
		_startTimeLabel.text = @"all-day";
		_endTimeLabel.text = nil;
	} else {
		
		PWWidgetCalendar *widget = [PWWidgetCalendar widget];
		NSDateFormatter *dateFormatter = widget.dateFormatter;
		
		[dateFormatter setDateStyle:NSDateFormatterNoStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		
		NSString *startTimeText = [dateFormatter stringFromDate:startDate];
		NSString *endTimeText = [dateFormatter stringFromDate:endDate];
		
		_startTimeLabel.text = startTimeText;
		_endTimeLabel.text = endTimeText;
	}
}

- (void)setCalendarColor:(UIColor *)color {
	_separator.backgroundColor = color;
}

- (void)setTitleTextColor:(UIColor *)color {
	
	UIColor *lightColor = [PWTheme translucentColor:color];
	
	_titleLabel.textColor = color;
	_locationLabel.textColor = lightColor;
	_startTimeLabel.textColor = color;
	_endTimeLabel.textColor = lightColor;
}

- (void)dealloc {
	RELEASE_VIEW(_separator)
	RELEASE_VIEW(_titleLabel)
	RELEASE_VIEW(_locationLabel)
	RELEASE_VIEW(_startTimeLabel)
	RELEASE_VIEW(_endTimeLabel)
	[super dealloc];
}

@end