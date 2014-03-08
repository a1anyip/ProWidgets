//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"

typedef enum {
	
	PWBackgroundViewAnimationTypeNone,
	PWBackgroundViewAnimationTypeResize,
	PWBackgroundViewAnimationTypePresentation,
	PWBackgroundViewAnimationTypeMaximization
	
} PWBackgroundViewAnimationType;

@interface PWBackgroundView : UIView {
	
	CAShapeLayer *_mask;
	
	NSUInteger _finalPathCount;
	CGPathRef _finalPath;
}

- (void)show;
- (void)hide;

- (void)clearMask;
- (void)setMaskRect:(CGRect)rect fromRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius animationType:(PWBackgroundViewAnimationType)animationType;

@end