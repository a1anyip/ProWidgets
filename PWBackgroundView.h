//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"

@interface PWBackgroundView : UIView {
	
	BOOL _shouldAnimateTransform;
	CAShapeLayer *_mask;
	
	NSUInteger _finalPathCount;
	CGPathRef _finalPath;
}

@property(nonatomic) BOOL shouldAnimateTransform;

- (void)show:(BOOL)shouldAnimateTransform;
- (void)hide;

- (void)clearMask;
- (void)setMaskRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius animated:(BOOL)animated;

@end