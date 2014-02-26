//
//  ProWidgets
//  Google Authenticator
//
//  Created by Alan Yip on 22 Feb 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "Cell.h"
#import "Notes.h"
#import "PWTheme.h"

@implementation PWWidgetNotesTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		self.detailTextLabel.textAlignment = NSTextAlignmentLeft;
		self.textLabel.textAlignment = NSTextAlignmentRight;
		
		self.detailTextLabel.font = [UIFont boldSystemFontOfSize:16.0];
		self.textLabel.font = [UIFont systemFontOfSize:16.0];
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGRect textRect = self.textLabel.frame;
	CGRect detailTextRect = self.detailTextLabel.frame;
	
	CGFloat textRectX = textRect.origin.x;
	textRect.origin.x = detailTextRect.origin.x + detailTextRect.size.width - textRect.size.width;
	detailTextRect.origin.x = textRectX - 4.0 /* minux the extra left margin */;
	
	self.textLabel.frame = textRect;
	self.detailTextLabel.frame = detailTextRect;
}

- (void)setTitle:(NSString *)title {
	self.detailTextLabel.text = title;
}

- (void)setDate:(NSDate *)date {
	NSString *dateText = [(PWWidgetNotes *)[PWController activeWidget] parseDate:date];
	self.textLabel.text = dateText;
}

- (void)setTitleTextColor:(UIColor *)color {
	self.detailTextLabel.textColor = color;
}

- (void)setValueTextColor:(UIColor *)color {
	self.textLabel.textColor = color;
}

- (void)setSelectedTitleTextColor:(UIColor *)color {
	self.detailTextLabel.highlightedTextColor = color;
}

- (void)setSelectedValueTextColor:(UIColor *)color {
	self.textLabel.highlightedTextColor = color;
}

@end