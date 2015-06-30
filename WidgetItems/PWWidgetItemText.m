//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWWidgetItemText.h"
#import "../PWWidget.h"

@implementation PWWidgetItemText

+ (Class)cellClass {
	return [PWWidgetItemTextCell class];
}

- (CGFloat)cellHeightForOrientation:(PWWidgetOrientation)orientation {
	
	NSString *text = self.title;
	CGSize maxSize = CGSizeMake([self textWidth], CGFLOAT_MAX);
	
	// create a paragraph style with specific line break mode
	NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
	paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
	paragraphStyle.alignment = NSTextAlignmentCenter;
	
	// create attributes
	NSDictionary *attributes = @{ NSFontAttributeName:[self textFont], NSParagraphStyleAttributeName:paragraphStyle };
	[paragraphStyle release];
	
	// calculate the rect
	CGRect rect = [text boundingRectWithSize:maxSize
									 options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
								  attributes:attributes
									 context:nil];
	
	return ceilf(rect.size.height) + PWDefaultItemCellPadding * 2;
}

- (CGFloat)textWidth {
	UITableView *tableView = self.itemViewController.tableView;
	return tableView.bounds.size.width - PWDefaultItemCellPadding * 2;
}

- (UIFont *)textFont {
	return [UIFont systemFontOfSize:16.0];
}

@end

@implementation PWWidgetItemTextCell

//////////////////////////////////////////////////////////////////////

+ (PWWidgetItemCellStyle)cellStyle {
	return PWWidgetItemCellStyleText;
}

//////////////////////////////////////////////////////////////////////

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier theme:(PWTheme *)theme {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier theme:theme])) {
		
		self.textLabel.numberOfLines = 0;
		self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
		self.textLabel.textAlignment = NSTextAlignmentCenter;
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGFloat textWidth = [(PWWidgetItemText *)self.item textWidth];
	if (textWidth <= 0) return;
	
	CGRect contentViewRect = self.contentView.bounds;
	contentViewRect.origin.x = (contentViewRect.size.width - textWidth) / 2;
	contentViewRect.size.width = textWidth;
	
	self.textLabel.frame = contentViewRect;
}

- (void)updateItem:(PWWidgetItem *)item {
	self.textLabel.font = [(PWWidgetItemText *)self.item textFont];
}

//////////////////////////////////////////////////////////////////////

- (void)setTitle:(NSString *)title {
	self.textLabel.text = title;
}

//////////////////////////////////////////////////////////////////////

- (void)setTitleTextColor:(UIColor *)color {}

- (void)setPlainTextColor:(UIColor *)color {
	self.textLabel.textColor = color;
}

@end