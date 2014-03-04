//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWMiniView.h"

@implementation PWMiniView

- (instancetype)initWithSnapshot:(UIImage *)snapshot {
	if ((self = [super init])) {
		
		_overlayView = [UIView new];
		_overlayView.userInteractionEnabled = NO;
		_overlayView.backgroundColor = [UIColor blackColor];
		_overlayView.alpha = .2;
		[self addSubview:_overlayView];
		
		self.userInteractionEnabled = YES;
		self.image = snapshot;
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	_overlayView.frame = self.bounds;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[UIView animateWithDuration:.1 animations:^{
		_overlayView.alpha = 0.0;
	}];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[UIView animateWithDuration:.1 animations:^{
		_overlayView.alpha = .2;
	}];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[UIView animateWithDuration:.1 animations:^{
		_overlayView.alpha = .2;
	}];
}

- (void)dealloc {
	RELEASE_VIEW(_overlayView)
	[super dealloc];
}

@end