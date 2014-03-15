//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWWidget.h"
#import "PWContentItemViewController.h"

@interface PWWidgetTest : PWWidget {
	
	//BOOL _showingA;
	
	PWContentItemViewController *_test;
	//PWContentItemViewController *_b;
}

@end

@implementation PWWidgetTest

- (void)willPresent {
	
	_test = [PWContentItemViewController new];
	_test.shouldAutoConfigureStandardButtons = YES;
	[_test setTitle:@"test title"];
	[_test loadPlist:@"TestItems"];
	
	[_test setItemValueChangedEventBlockHandler:^(NSDictionary *dict) {
		LOG(@"itemValueChangedEventBlockHandler: %@", dict);
	}];
	
	[_test setSubmitEventBlockHandler:^(NSDictionary *values) {
		LOG(@"submitEventBlockHandler: %@", values);
	}];
	
	[_test setSubmitEventHandler:self selector:@selector(action::)];
	
	[self pushViewController:_test animated:NO];
	[_test release];
}

- (void)action:(id)first :(id)second {
	LOG(@"action!!!!!!! %@", second);
}

@end