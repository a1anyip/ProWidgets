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
	
	UILabel *_timeLabel;
	UILabel *_titleLabel;
}

- (void)setActive:(BOOL)active;
- (void)setHour:(NSUInteger)hour minute:(NSUInteger)minute;
- (void)setTitle:(NSString *)title daySetting:(NSUInteger)daySetting;

@end