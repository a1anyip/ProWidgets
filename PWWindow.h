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
	
	BOOL _adjustedLayout;
	UIInterfaceOrientation _currentOrientation;
}

- (void)adjustLayout;

- (CGAffineTransform)orientationToTransform:(UIInterfaceOrientation)orientation;

@end