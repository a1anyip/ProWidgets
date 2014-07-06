//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "FolderItemTableViewCell.h"

@implementation PWBrowserWidgetItemFolderTableViewCell

- (void)layoutSubviews {
	[super layoutSubviews];
	
	const CGFloat indentationWidth = self.imageView.frame.size.width;
	const CGFloat padding = 12.0;
	
	self.separatorInset = UIEdgeInsetsMake(0, (self.indentationLevel * indentationWidth) + 15, 0, 0);
	
	self.imageView.frame = CGRectMake(self.imageView.frame.origin.x + (self.indentationLevel * indentationWidth), self.imageView.frame.origin.y, self.imageView.frame.size.width, self.imageView.frame.size.height);
	
	self.textLabel.frame = CGRectMake(self.imageView.frame.origin.x + self.imageView.frame.size.width + padding, self.textLabel.frame.origin.y, self.frame.size.width - self.imageView.frame.origin.x - self.imageView.frame.size.width - padding * 2, self.textLabel.frame.size.height);
}

@end