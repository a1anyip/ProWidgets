//
//  ProWidgets
//  Google Authenticator
//
//  Created by Alan Yip on 22 Feb 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "Cell.h"
#import "PWTheme.h"

@implementation PWWidgetCalendarTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		
		// time label
		_timeLabel = [UILabel new];
		_timeLabel.backgroundColor = [UIColor clearColor];
		_timeLabel.font = [UIFont systemFontOfSize:48.0];
		_timeLabel.textColor = [UIColor blackColor];
		[self.contentView addSubview:_timeLabel];
		
		// text label
		_titleLabel = [UILabel new];
		_titleLabel.backgroundColor = [UIColor clearColor];
		_titleLabel.textColor = [UIColor colorWithWhite:.5 alpha:1.0];
		_titleLabel.font = [UIFont systemFontOfSize:16.0];
		[self.contentView addSubview:_titleLabel];
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGSize size = self.bounds.size;
	CGFloat width = size.width;
	CGFloat height = size.height;
	CGFloat horizontalPadding = 15.0;
	CGFloat timeHeight = 45.0;
	CGFloat titleHeight = 20.0;
	CGFloat contentHeight = timeHeight + titleHeight;
	
	CGRect timeRect = CGRectMake(horizontalPadding, (height - contentHeight) / 2, width - horizontalPadding * 2, timeHeight);
	CGRect titleRect = CGRectMake(horizontalPadding, timeRect.origin.y + timeRect.size.height, width - horizontalPadding * 2, titleHeight);
	
	_timeLabel.frame = timeRect;
	_titleLabel.frame = titleRect;
}

- (void)setActive:(BOOL)active {
	self.contentView.alpha = active ? 1.0 : 0.3;
}

- (void)setHour:(NSUInteger)hour minute:(NSUInteger)minute {
	NSString *timeText = [NSString stringWithFormat:@"%02d:%02d", (int)hour, (int)minute];
	_timeLabel.text = timeText;
}

- (void)setTitle:(NSString *)title daySetting:(NSUInteger)daySetting {
	NSString *daySettingText = nil;
	NSString *titleText = nil;
	if (daySettingText == nil) {
		titleText = title;
	} else {
		titleText = [NSString stringWithFormat:@"%@, %@", title, daySettingText];
	}
	_titleLabel.text = titleText;
}

- (void)setTitleTextColor:(UIColor *)color {
	_timeLabel.textColor = color;
	_titleLabel.textColor = color;
}

- (void)dealloc {
	RELEASE_VIEW(_timeLabel)
	RELEASE_VIEW(_titleLabel)
	[super dealloc];
}

@end