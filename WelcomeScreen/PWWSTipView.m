//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWWSTipView.h"
#import "../PWController.h"

#define IMAGE_MAX_HEIGHT 269.0

@implementation PWWSTipView

- (instancetype)initWithTitle:(NSString *)title content:(NSString *)content imageName:(NSString *)imageName {
	if ((self = [super init])) {
		
		self.userInteractionEnabled = NO;
		self.backgroundColor = [UIColor clearColor];
		
		UIImage *image = [[PWController sharedInstance] imageResourceNamed:[NSString stringWithFormat:@"WelcomeScreen/%@", imageName]];
		
		_imageView = [UIImageView new];
		_imageView.image = image;
		_imageView.contentMode = UIViewContentModeScaleAspectFit;
		[self addSubview:_imageView];
		
		_titleLabel = [UILabel new];
		_titleLabel.text = title;
		_titleLabel.font = [UIFont boldSystemFontOfSize:24.0];
		_titleLabel.textAlignment = NSTextAlignmentCenter;
		_titleLabel.textColor = [UIColor blackColor];
		[self addSubview:_titleLabel];
		
		_contentView = [UITextView new];
		_contentView.editable = NO;
		_contentView.selectable = NO;
		_contentView.textColor = [UIColor blackColor];
		_contentView.backgroundColor = [UIColor clearColor];
		_contentView.alpha = .4;
		[self addSubview:_contentView];
		
		const CGFloat lineHeight = 25.0;
		NSMutableParagraphStyle *style = [[NSMutableParagraphStyle new] autorelease];
		style.minimumLineHeight = lineHeight;
		style.maximumLineHeight = lineHeight;
		style.alignment = NSTextAlignmentCenter;
		
		_contentView.attributedText = [[[NSAttributedString alloc] initWithString:content attributes:@{ NSParagraphStyleAttributeName: style, NSFontAttributeName: [UIFont systemFontOfSize:16.0] }] autorelease];
	}
	return self;
}

- (void)layoutSubviews {
	
	[super layoutSubviews];
	
	CGSize size = self.bounds.size;
	CGFloat width = size.width;
	CGFloat height = size.height;
	
	CGFloat labelMargin = 10.0;
	CGFloat titleHeight = 28.0;
	CGFloat contentHeight = 110.0;
	CGFloat imageBottomMargin = 20.0;
	CGFloat imageHeight = MIN(height - titleHeight - contentHeight - imageBottomMargin, IMAGE_MAX_HEIGHT);
	CGFloat topMargin = (height - titleHeight - contentHeight - imageHeight - imageBottomMargin) / 2.0;
	
	CGRect imageRect = CGRectMake(0, topMargin, width, imageHeight);
	CGRect titleRect = CGRectMake(labelMargin, topMargin + imageHeight + imageBottomMargin, width - labelMargin * 2, titleHeight);
	CGRect contentRect = CGRectMake(labelMargin, titleRect.origin.y + titleHeight, width - labelMargin * 2, contentHeight);
	
	_imageView.frame = imageRect;
	_titleLabel.frame = titleRect;
	_contentView.frame = contentRect;
}

- (void)dealloc {
	DEALLOCLOG;
	RELEASE_VIEW(_imageView)
	RELEASE_VIEW(_titleLabel)
	RELEASE_VIEW(_contentView)
	[super dealloc];
}

@end