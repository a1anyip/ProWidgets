//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWWidget.h"

@interface PWWidgetCustom : PWWidget {
	
}

@end

@implementation PWWidgetCustom

- (CGSize)overrideSize {
	return CGSizeMake(290, 350);
}

- (void)action:(NSDictionary *)values {
	
	[self removeItemAtIndex:2 animated:NO];
}

@end