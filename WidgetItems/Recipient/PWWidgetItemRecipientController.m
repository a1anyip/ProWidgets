//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWWidgetItemRecipientController.h"

@implementation PWWidgetItemRecipientController

- (instancetype)init {
	if ((self = [super init])) {
		self.automaticallyAdjustsScrollViewInsets = NO;
		self.requiresKeyboard = NO;
		self.shouldMaximizeContentHeight = YES;
	}
	return self;
}

@end