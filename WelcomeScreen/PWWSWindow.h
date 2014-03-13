//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "../header.h"
#import "interface.h"

@interface PWWSWindow : UIWindow {
	
	UIView *_overlayView;
	_SBFakeBlurView *_blurView;
	UIImageView *_logoView;
	UIView *_buttonBackgroundView;
	UIButton *_button;
}

- (void)adjustLayout;
- (void)fadeOutOverlayView;

@end