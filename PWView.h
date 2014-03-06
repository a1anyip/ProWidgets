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
}

@property(nonatomic, readonly) PWBackgroundView *backgroundView;

- (void)updateBackgroundViewRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius animated:(BOOL)animated;

@end