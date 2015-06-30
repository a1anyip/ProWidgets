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

@interface PWWSWindow : UIWindow<UIScrollViewDelegate> {
	
	BOOL _showingTips;
	BOOL _ready;
	
	CGFloat _previousBacklightFactor;
	
	// global views
	UIView *_overlayView;
	_SBFakeBlurView *_blurView;
	UIImageView *_logoView;
	
	// welcome view
	UILabel *_welcomeTitleLabel;
	UILabel *_welcomeMessageLabel;
	UIView *_buttonBackgroundView;
	UIButton *_button;
	
	// tips views
	UIScrollView *_scrollView;
	UIPageControl *_pageControl;
}

- (void)adjustLayout;
- (void)fadeOutOverlayView;

- (void)show;
- (void)hide;

- (void)proceed;

- (void)prepareScrollView;
- (NSArray *)tips;

@end