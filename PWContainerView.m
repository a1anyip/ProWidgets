//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWContainerView.h"
#import "PWController.h"
#import "PWTheme.h"

@implementation PWContainerView

- (instancetype)init {
	if (self = [super init]) {
		
		self.userInteractionEnabled = YES;
		self.backgroundColor = [UIColor clearColor];
		self.clipsToBounds = YES;
		
		// create sheet background view
		_containerBackgroundView = [UIImageView new];
		_containerBackgroundView.userInteractionEnabled = NO;
		[self addSubview:_containerBackgroundView];
	}
	return self;
}

//////////////////////////////////////////////////////////////////////

/**
 * UI Manipulation
 **/

- (void)layoutSubviews {
	
	_containerBackgroundView.frame = self.bounds;
	[_containerBackgroundView layoutIfNeeded];
	
	_navigationControllerView.frame = self.bounds;
	[_navigationControllerView layoutIfNeeded];
	
	[[PWController activeTheme] adjustLayout];
	
	// tell active theme to adjust layout
	//[[PWController activeTheme] performSelectorOnMainThread:@selector(adjustLayout) withObject:nil waitUntilDone:NO];
}

- (void)dealloc {
	
	DEALLOCLOG;
	
	RELEASE_VIEW(_containerBackgroundView)
	[_navigationControllerView removeFromSuperview], _navigationControllerView = nil;
	
	[super dealloc];
}

@end