//
//  ProWidgets
//  Notification Center
//
//  Created by Alan Yip on 22 Feb 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "Controller.h"

@implementation PWNCController

- (void)loadView {
	self.view = [[PWNCView new] autorelease];
}

- (CGSize)preferredViewSize {
	return CGSizeMake(0.0, 70.0);
}

- (void)hostWillPresent {
	[(PWNCView *)self.view load];
	[(PWNCView *)self.view resetPage];
}

- (void)hostDidDismiss {
	[(PWNCView *)self.view unload];
}

@end