//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"
#import "interface.h"
#import "PWController.h"

%hook SpringBoard

- (void)applicationOpenURL:(NSURL *)url withApplication:(id)application sender:(id)sender publicURLsOnly:(BOOL)only animating:(BOOL)animating needsPermission:(BOOL)permission additionalActivationFlags:(id)flags activationHandler:(id)handler {
	
	NSString *scheme = [[url scheme] lowercaseString];
	NSString *urlString = url.absoluteString;
	if (([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]) && urlString != nil) {
		PWController *controller = [PWController sharedInstance];
		NSDictionary *userInfo = @{ @"from": @"app", @"url": urlString };
		[controller presentWidgetNamed:@"Browser" userInfo:userInfo];
	} else {
		%orig;
	}
}

%end