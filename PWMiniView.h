//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"

@interface PWMiniView : UIImageView {
	
	BOOL _dragging;
	UIView *_containerView;
	UIView *_overlayView;
	CGFloat _scale;
}

@property(nonatomic, assign) CGFloat scale;

- (instancetype)initWithContainerView:(UIView *)containerView requiresLivePreview:(BOOL)requiresLivePreview;
- (void)setDragging:(BOOL)dragging;
- (void)finishAnimation;

@end