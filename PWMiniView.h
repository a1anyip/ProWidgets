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
	
	UIView *_overlayView;
}

- (instancetype)initWithSnapshot:(UIImage *)snapshot;
- (void)finishAnimation;

@end