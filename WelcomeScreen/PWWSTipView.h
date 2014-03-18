//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "../header.h"

@interface PWWSTipView : UIView {
	
	UIImageView *_imageView;
	UILabel *_titleLabel;
	UITextView *_contentView;
}

- (instancetype)initWithTitle:(NSString *)title content:(NSString *)content imageName:(NSString *)imageName;

@end