//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"
#import "PWController.h"
#import "PWBackgroundView.h"
#import "PWContainerView.h"
#import "PWMiniView.h"

@interface PWView : UIView {
	
	PWBackgroundView *_backgroundView;
	PWContainerView *_containerView;
}

@property(nonatomic, readonly) PWBackgroundView *backgroundView;
@property(nonatomic, readonly) PWContainerView *containerView;

- (void)createContainerView;
- (void)removeContainerView;

- (void)keyboardWillShow:(CGFloat)height;
- (void)keyboardWillHide;

- (CGRect)containerRect;

- (void)_updateBackgroundViewRect:(CGRect)rect animated:(BOOL)animated;
- (void)_resizeWidgetAnimated:(BOOL)animated;

@end