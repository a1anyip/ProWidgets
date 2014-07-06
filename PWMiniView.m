//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWMiniView.h"

#define kOverlayViewActiveAlpha 0.15
#define kOverlayViewInactiveAlpha 0.0

@implementation PWMiniView

- (instancetype)initWithContainerView:(UIView *)containerView {
	if ((self = [super init])) {
		
		_containerView = containerView;
		[containerView retain];
		[containerView removeFromSuperview];
		[self addSubview:containerView];
		[containerView release];
		
		_overlayView = [UIView new];
		_overlayView.userInteractionEnabled = NO;
		_overlayView.backgroundColor = [UIColor blackColor];
		_overlayView.alpha = kOverlayViewInactiveAlpha;
		[self addSubview:_overlayView];
		
		self.layer.shouldRasterize = YES;
		self.userInteractionEnabled = YES;
		
		[UIView animateWithDuration:.3 animations:^{
			_overlayView.alpha = kOverlayViewActiveAlpha;
		}];
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	_containerView.frame = self.bounds;
	_overlayView.frame = self.bounds;
}

- (void)setDragging:(BOOL)dragging {
	
	_dragging = dragging;
	
	if (dragging) {
		_overlayView.alpha = kOverlayViewInactiveAlpha;
	} else {
		_overlayView.alpha = kOverlayViewActiveAlpha;
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	_overlayView.alpha = kOverlayViewInactiveAlpha;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	_overlayView.alpha = kOverlayViewInactiveAlpha;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	_overlayView.alpha = kOverlayViewActiveAlpha;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!_dragging) {
		_overlayView.alpha = kOverlayViewActiveAlpha;
	}
}

- (void)finishAnimation {
	
	CALayer *layer = self.layer;
	
	layer.cornerRadius = 10.0;//20.0;
	layer.borderColor = [UIColor colorWithWhite:.3 alpha:.6].CGColor;
	layer.borderWidth = 2.0;
	
	/*
	layer.shadowColor = [UIColor blackColor].CGColor;
	layer.shadowOffset = CGSizeMake(1, 1);
	layer.shadowOpacity = .25;
	layer.shadowRadius = 4.0;
	*/
	
	/*[UIView animateWithDuration:.15 animations:^{
		_overlayView.alpha = kOverlayViewActiveAlpha;
	}];*/
}

- (void)dealloc {
	RELEASE_VIEW(_overlayView)
	[super dealloc];
}

@end