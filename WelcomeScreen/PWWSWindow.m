//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWWSWindow.h"
#import "../PWController.h"

@implementation PWWSWindow

- (instancetype)init {
	if (self = [super init]) {
		
		// Window Levels
		// (Cut/Copy) UITextEffectsWindow	2100
		// (Undo/Cancel) ~Alert window		1996
		// Notification Center				1056
		// Control Center					1056
		// === PWWindow ===					1055
		// Lock Alert Window				1050
		// UIWindowLevelStatusBar			1000
		
		self.windowLevel = 9999.0;
		self.backgroundColor = [UIColor whiteColor];
		self.userInteractionEnabled = YES;
		self.frame = [[UIScreen mainScreen] bounds];
		self.hidden = NO;
		
		_blurView = [[objc_getClass("_SBFakeBlurView") alloc] initWithVariant:0];
		_blurView.userInteractionEnabled = NO;
		[_blurView requestStyle:16];
		[self addSubview:_blurView];
		
		UIImage *logoImage = [[PWController sharedInstance] imageResourceNamed:@"WelcomeScreen/logo"];
		_logoView = [UIImageView new];
		_logoView.backgroundColor = [UIColor clearColor];
		_logoView.contentMode = UIViewContentModeScaleAspectFit;
		_logoView.image = logoImage;
		[self addSubview:_logoView];
		
		_buttonBackgroundView = [UIView new];
		_buttonBackgroundView.backgroundColor = [UIColor whiteColor];
		_buttonBackgroundView.alpha = .2;
		[self addSubview:_buttonBackgroundView];
		
		_button = [UIButton new];
		_button.titleLabel.font = [UIFont systemFontOfSize:22.0];
		_button.backgroundColor = [UIColor clearColor];
		[_button setTitleColor:[UIColor colorWithWhite:0.0 alpha:.5] forState:UIControlStateNormal];
		[_button setTitle:@"Proceed" forState:UIControlStateNormal];
		[_button addTarget:self action:@selector(buttonTouchDown) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragInside | UIControlEventTouchDragEnter];
		[_button addTarget:self action:@selector(buttonTouchUp) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchDragOutside | UIControlEventTouchDragExit | UIControlEventTouchCancel];
		[_button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_button];
		
		_overlayView = [UIView new];
		_overlayView.backgroundColor = [UIColor whiteColor];
		_overlayView.alpha = 1.0;
		[self addSubview:_overlayView];
		
		[self adjustLayout];
		[self fadeOutOverlayView];
	}
	return self;
}

- (void)adjustLayout {
	
	CGSize size = self.bounds.size;
	CGFloat width = size.width;
	CGFloat height = size.height;
	
	CGFloat topMargin = 60.0;
	CGFloat logoHeight = 48.5;
	CGFloat buttonHeight = 70.0;
	
	CGRect buttonRect = CGRectMake(0, height - buttonHeight, width, buttonHeight);
	
	_overlayView.frame = self.bounds;
	_blurView.frame = self.bounds;
	_logoView.frame = CGRectMake(0, topMargin, width, logoHeight);
	_buttonBackgroundView.frame = buttonRect;
	_button.frame = buttonRect;
}

- (void)fadeOutOverlayView {
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
		[UIView animateWithDuration:.5 animations:^{
			_overlayView.alpha = 0.0;
		} completion:^(BOOL finished) {
			RELEASE_VIEW(_overlayView)
		}];
	});
}

- (void)buttonTouchDown {
	[UIView animateWithDuration:.1 animations:^{
		_buttonBackgroundView.alpha = .35;
	}];
}

- (void)buttonTouchUp {
	[UIView animateWithDuration:.1 animations:^{
		_buttonBackgroundView.alpha = .2;
	}];
}

- (void)buttonPressed {
	self.hidden = YES;
}

- (void)dealloc {
	DEALLOCLOG;
	RELEASE_VIEW(_overlayView)
	RELEASE_VIEW(_blurView)
	RELEASE_VIEW(_logoView)
	RELEASE_VIEW(_buttonBackgroundView)
	RELEASE_VIEW(_button)
	[super dealloc];
}

@end