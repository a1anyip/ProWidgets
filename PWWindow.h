//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"

@interface PWWindow : UIWindow {
	
	BOOL _recordedLastPosition;
	CGPoint _lastPosition;
	PWMiniView *_miniView;
}

@property(nonatomic, readonly) PWMiniView *miniView;

- (void)adjustLayout;

- (void)show;
- (void)hide;

- (PWMiniView *)createMiniViewWithSnapshot:(UIImage *)snapshot;
- (void)removeMiniView;
- (CGPoint)getInitialPositionOfMiniView;

- (CGAffineTransform)orientationToTransform:(UIInterfaceOrientation)orientation;

@end