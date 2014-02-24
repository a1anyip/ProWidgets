//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWJSBridgeWrapper.h"

@implementation PWJSBridgeWrapper

- (instancetype)initWithJSBridge:(PWJSBridge *)bridge {
	if ((self = [super init])) {
		_bridge = bridge;
	}
	return self;
}

- (void)dealloc {
	
	// clear reference
	_bridge = nil;
	
	[super dealloc];
}

@end